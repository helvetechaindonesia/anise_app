const express = require('express');
const cors = require('cors');
const qrcode = require('qrcode');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const {
    default: makeWASocket,
    DisconnectReason,
    useMultiFileAuthState,
    fetchLatestBaileysVersion
} = require('@whiskeysockets/baileys');
const pino = require('pino');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3001;
const API_KEY = process.env.API_KEY || 'anise_secret_gateway_key_2026';
const SESSION_DIR = process.env.SESSION_DIR || path.join(__dirname, 'sessions');

if (!fs.existsSync(SESSION_DIR)) {
    fs.mkdirSync(SESSION_DIR, { recursive: true });
}

let sock = null;
let currentQR = null;
let isConnected = false;
let botUser = null;

async function startWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState(SESSION_DIR);
    const { version } = await fetchLatestBaileysVersion();

    sock = makeWASocket({
        version,
        logger: pino({ level: 'silent' }),
        printQRInTerminal: true,
        auth: state,
        browser: ['Anise School App', 'Chrome', '1.0.0']
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;

        if (qr) {
            currentQR = qr;
            console.log('[WA Gateway] QR Code baru siap untuk di-scan!');
        }

        if (connection === 'close') {
            isConnected = false;
            botUser = null;
            const statusCode = (lastDisconnect?.error)?.output?.statusCode;
            console.log(`[WA Gateway] Koneksi terputus (Status: ${statusCode})`);

            // Jika status 500 atau 401 atau session corrupt, bersihkan session agar generate QR baru
            if (statusCode === 500 || statusCode === DisconnectReason.loggedOut || statusCode === 401) {
                console.log('[WA Gateway] Session korup / kedaluwarsa. Membersihkan session folder untuk QR baru...');
                try {
                    fs.rmSync(SESSION_DIR, { recursive: true, force: true });
                    fs.mkdirSync(SESSION_DIR, { recursive: true });
                } catch (_) {}
                setTimeout(startWhatsApp, 2000);
            } else {
                setTimeout(startWhatsApp, 3000);
            }
        } else if (connection === 'open') {
            isConnected = true;
            currentQR = null;
            botUser = sock.user;
            console.log('[WA Gateway] WhatsApp Bot TERHUBUNG sebagai:', sock.user?.id);
        }
    });
}

// -------------------------------------------------------------
// ROUTES
// -------------------------------------------------------------

// 1. Status Info
app.get('/', (req, res) => {
    res.json({
        service: 'Anise Self-Hosted WhatsApp Gateway',
        status: isConnected ? 'CONNECTED' : 'WAITING_FOR_SCAN',
        user: botUser ? botUser.id : null,
        scan_url: `http://${req.headers.host}/scan`
    });
});

// 2. Scan QR Page di Web Browser
app.get('/scan', async (req, res) => {
    if (isConnected) {
        return res.send(`
            <!DOCTYPE html>
            <html>
            <head><title>Anise WhatsApp Gateway - Connected</title></head>
            <body style="font-family: sans-serif; text-align: center; padding-top: 50px; background: #f0fdf4;">
                <h1 style="color: #166534;">✅ WhatsApp Terhubung!</h1>
                <p>Nomor Bot: <strong>${botUser ? botUser.id.split(':')[0] : 'Aktif'}</strong></p>
                <p>Gateway siap mengirim pesan otomatis dari Anise App.</p>
            </body>
            </html>
        `);
    }

    if (!currentQR) {
        return res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Anise WhatsApp Gateway</title>
                <meta http-equiv="refresh" content="3">
            </head>
            <body style="font-family: sans-serif; text-align: center; padding-top: 50px;">
                <h2>⏳ Menyiapkan QR Code...</h2>
                <p>Halaman akan otomatis refresh dalam 3 detik...</p>
            </body>
            </html>
        `);
    }

    try {
        const qrImage = await qrcode.toDataURL(currentQR);
        res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Tautkan WhatsApp - Anise Gateway</title>
                <meta http-equiv="refresh" content="20">
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f8fafc; text-align: center; padding: 40px 20px; }
                    .card { max-width: 420px; margin: 0 auto; background: white; padding: 30px; border-radius: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); }
                    h2 { color: #1C3F4A; margin-bottom: 8px; }
                    p { color: #64748b; font-size: 14px; margin-bottom: 20px; }
                    img { border-radius: 12px; border: 1px solid #e2e8f0; }
                    .note { margin-top: 20px; font-size: 12px; color: #94a3b8; }
                </style>
            </head>
            <body>
                <div class="card">
                    <h2>📲 Tautkan Perangkat WhatsApp</h2>
                    <p>Buka WhatsApp di HP Anda &gt; Setelan &gt; <strong>Perangkat Tertaut</strong> &gt; Tautkan Perangkat, lalu scan QR di bawah ini:</p>
                    <img src="${qrImage}" width="280" height="280" alt="WhatsApp QR Code" />
                    <div class="note">QR Code akan diperbarui otomatis setiap 20 detik jika belum di-scan.</div>
                </div>
            </body>
            </html>
        `);
    } catch (err) {
        res.status(500).send('Gagal membuat gambar QR: ' + err.message);
    }
});

// 3. API Status
app.get('/status', (req, res) => {
    res.json({
        connected: isConnected,
        user: botUser ? botUser.id : null
    });
});

// 4. API Send Message (Dipanggil oleh Laravel Backend)
app.post('/send-message', async (req, res) => {
    const authHeader = req.headers['x-api-key'] || req.headers['authorization'];
    if (authHeader && authHeader.replace('Bearer ', '') !== API_KEY) {
        return res.status(401).json({ status: 'error', message: 'API Key tidak valid' });
    }

    const { phone, message } = req.body;

    if (!phone || !message) {
        return res.status(400).json({ status: 'error', message: 'Field phone dan message wajib diisi' });
    }

    if (!isConnected || !sock) {
        return res.status(503).json({
            status: 'error',
            message: 'WhatsApp Gateway belum terhubung. Silakan buka /scan untuk menautkan perangkat.'
        });
    }

    try {
        let cleanPhone = phone.toString().replace(/[^0-9]/g, '');
        if (cleanPhone.startsWith('0')) {
            cleanPhone = '62' + cleanPhone.substring(1);
        } else if (cleanPhone.startsWith('+62')) {
            cleanPhone = cleanPhone.substring(1);
        }

        const jid = `${cleanPhone}@s.whatsapp.net`;

        const sent = await sock.sendMessage(jid, { text: message });

        return res.json({
            status: 'success',
            message: 'Pesan WhatsApp berhasil dikirim',
            data: {
                target: cleanPhone,
                message_id: sent?.key?.id
            }
        });
    } catch (error) {
        console.error('[WA Gateway] Gagal kirim pesan:', error);
        return res.status(500).json({
            status: 'error',
            message: 'Gagal mengirim pesan WhatsApp: ' + error.message
        });
    }
});

startWhatsApp();

app.listen(PORT, '0.0.0.0', () => {
    console.log(`=======================================================`);
    console.log(`🚀 Anise WhatsApp Gateway berjalan di port ${PORT}`);
    console.log(`📱 Buka URL berikut di browser untuk scan QR:`);
    console.log(`   http://localhost:${PORT}/scan`);
    console.log(`=======================================================`);
});
