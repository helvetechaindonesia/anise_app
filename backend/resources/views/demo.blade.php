<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sipena (Anise App) - Live Web Demo (Google Play Reviewer Access)</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <!-- Phosphor Icons -->
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    
    <style>
        :root {
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --primary-light: #dbeafe;
            --secondary: #0284c7;
            --accent: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --bg-dark: #090d16;
            --card-dark: #111827;
            --surface-glass: rgba(255, 255, 255, 0.04);
            --surface-border: rgba(255, 255, 255, 0.08);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --phone-width: 380px;
            --phone-height: 780px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            -webkit-tap-highlight-color: transparent;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
            background-image: 
                radial-gradient(circle at 15% 20%, rgba(37, 99, 235, 0.12) 0%, transparent 40%),
                radial-gradient(circle at 85% 80%, rgba(16, 185, 129, 0.08) 0%, transparent 40%);
        }

        /* Top Navbar */
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 18px 40px;
            border-bottom: 1px solid var(--surface-border);
            backdrop-filter: blur(12px);
            background: rgba(9, 13, 22, 0.8);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .brand-logo {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 4px 16px rgba(37, 99, 235, 0.4);
        }

        .brand-text h1 {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -0.02em;
        }

        .brand-text p {
            font-size: 12px;
            color: var(--text-muted);
        }

        .badge-verified {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 20px;
            background: rgba(16, 185, 129, 0.12);
            border: 1px solid rgba(16, 185, 129, 0.3);
            color: #34d399;
            font-size: 12px;
            font-weight: 600;
        }

        /* Main Workspace */
        .workspace {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 60px;
            padding: 40px 20px;
            max-width: 1400px;
            margin: 0 auto;
            width: 100%;
        }

        /* Left Side: Info & Role Switcher */
        .control-panel {
            flex: 1;
            max-width: 480px;
        }

        .hero-tag {
            display: inline-block;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #60a5fa;
            background: rgba(37, 99, 235, 0.15);
            padding: 6px 12px;
            border-radius: 8px;
            margin-bottom: 16px;
        }

        .hero-title {
            font-size: 36px;
            font-weight: 800;
            line-height: 1.2;
            letter-spacing: -0.03em;
            margin-bottom: 14px;
            background: linear-gradient(to right, #ffffff, #94a3b8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero-desc {
            font-size: 15px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 28px;
        }

        .role-selector-title {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #cbd5e1;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .role-cards {
            display: grid;
            grid-template-columns: 1fr;
            gap: 10px;
            margin-bottom: 28px;
        }

        .role-card {
            background: var(--surface-glass);
            border: 1px solid var(--surface-border);
            border-radius: 14px;
            padding: 14px 18px;
            cursor: pointer;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .role-card:hover {
            border-color: rgba(37, 99, 235, 0.4);
            transform: translateX(4px);
            background: rgba(37, 99, 235, 0.06);
        }

        .role-card.active {
            border-color: var(--primary);
            background: rgba(37, 99, 235, 0.16);
            box-shadow: 0 4px 20px rgba(37, 99, 235, 0.25);
        }

        .role-card-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .role-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.05);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: #60a5fa;
            transition: all 0.2s;
        }

        .role-card.active .role-icon {
            background: var(--primary);
            color: #ffffff;
        }

        .role-info h4 {
            font-size: 14px;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 2px;
        }

        .role-info p {
            font-size: 12px;
            color: var(--text-muted);
        }

        .play-notice {
            background: rgba(255, 255, 255, 0.02);
            border: 1px dashed rgba(255, 255, 255, 0.12);
            border-radius: 14px;
            padding: 16px;
            font-size: 13px;
            color: #94a3b8;
            line-height: 1.5;
        }

        .play-notice strong {
            color: #38bdf8;
        }

        /* Right Side: Phone Device Frame */
        .phone-wrapper {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .phone-frame {
            width: var(--phone-width);
            height: var(--phone-height);
            background: #0f172a;
            border-radius: 46px;
            border: 10px solid #1e293b;
            box-shadow: 
                0 0 0 2px rgba(255, 255, 255, 0.1),
                0 25px 60px -15px rgba(0, 0, 0, 0.8),
                0 0 50px rgba(37, 99, 235, 0.15);
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        /* Phone Speaker Notch */
        .phone-notch {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 140px;
            height: 24px;
            background: #1e293b;
            border-bottom-left-radius: 16px;
            border-bottom-right-radius: 16px;
            z-index: 50;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .camera-lens {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #090d16;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        /* Phone Screen Content */
        .screen-container {
            flex: 1;
            background: #f8fafc;
            color: #0f172a;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }

        /* Mobile Status Bar */
        .mobile-statusbar {
            padding: 8px 24px 4px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 11px;
            font-weight: 700;
            color: #0f172a;
            z-index: 40;
            background: transparent;
        }

        .status-icons {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
        }

        /* Mobile Header */
        .mobile-header {
            padding: 12px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
        }

        .user-greeting {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .user-avatar-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #2563eb, #3b82f6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-weight: 700;
            font-size: 16px;
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.2);
        }

        .user-meta h3 {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
            line-height: 1.2;
        }

        .user-meta p {
            font-size: 11px;
            color: #64748b;
            font-weight: 500;
        }

        .role-pill {
            display: inline-block;
            font-size: 10px;
            font-weight: 700;
            background: #eff6ff;
            color: #2563eb;
            padding: 2px 8px;
            border-radius: 10px;
            margin-top: 2px;
        }

        /* Scrollable Screen Body */
        .screen-body {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            padding-bottom: 80px;
        }

        .screen-body::-webkit-scrollbar {
            width: 4px;
        }
        .screen-body::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }

        /* Mobile Cards & Widgets */
        .quick-banner {
            background: linear-gradient(135deg, #1e40af, #2563eb);
            border-radius: 18px;
            padding: 18px;
            color: #ffffff;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 20px -4px rgba(37, 99, 235, 0.4);
        }

        .quick-banner h4 {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .quick-banner p {
            font-size: 12px;
            opacity: 0.9;
            margin-bottom: 12px;
            line-height: 1.4;
        }

        .quick-badge-time {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(8px);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 4px;
        }

        .section-header h5 {
            font-size: 14px;
            font-weight: 700;
            color: #1e293b;
        }

        .section-header a {
            font-size: 12px;
            color: #2563eb;
            text-decoration: none;
            font-weight: 600;
        }

        /* Item Grid / List */
        .widget-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 14px 16px;
            border: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
            transition: transform 0.15s;
        }

        .widget-card:hover {
            transform: translateY(-2px);
        }

        .widget-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .widget-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .icon-blue { background: #dbeafe; color: #2563eb; }
        .icon-green { background: #d1fae5; color: #059669; }
        .icon-amber { background: #fef3c7; color: #d97706; }
        .icon-purple { background: #f3e8ff; color: #9333ea; }
        .icon-rose { background: #ffe4e6; color: #e11d48; }

        .widget-text h6 {
            font-size: 13px;
            font-weight: 700;
            color: #0f172a;
        }

        .widget-text p {
            font-size: 11px;
            color: #64748b;
        }

        .widget-badge {
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 8px;
        }

        .badge-success { background: #dcfce7; color: #166534; }
        .badge-pending { background: #fef9c3; color: #854d0e; }
        .badge-info { background: #e0f2fe; color: #075985; }

        /* Habit Progress Pill */
        .habit-progress-box {
            background: #ffffff;
            border-radius: 16px;
            padding: 16px;
            border: 1px solid #e2e8f0;
        }

        .habit-title-row {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
        }

        .progress-bar-bg {
            width: 100%;
            height: 8px;
            background: #f1f5f9;
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 8px;
        }

        .progress-bar-fill {
            height: 100%;
            background: linear-gradient(to right, #10b981, #059669);
            border-radius: 10px;
            width: 85%;
        }

        /* Mobile Bottom Navigation Bar */
        .mobile-bottom-nav {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 64px;
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-around;
            align-items: center;
            padding: 0 10px;
            z-index: 50;
        }

        .nav-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
            background: none;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            font-size: 10px;
            font-weight: 600;
            transition: color 0.15s;
        }

        .nav-btn i {
            font-size: 22px;
        }

        .nav-btn.active {
            color: #2563eb;
        }

        /* Footer */
        .demo-footer {
            text-align: center;
            padding: 24px;
            font-size: 13px;
            color: #64748b;
            border-top: 1px solid var(--surface-border);
        }

        @media (max-width: 900px) {
            .workspace {
                flex-direction: column;
                gap: 40px;
                padding: 20px;
            }
            .control-panel {
                max-width: 100%;
                text-align: center;
            }
            .role-selector-title {
                justify-content: center;
            }
            .topbar {
                padding: 14px 20px;
            }
        }
    </style>
</head>
<body>

    <!-- TOPBAR -->
    <header class="topbar">
        <div class="brand">
            <div class="brand-logo">
                <i class="ph-bold ph-graduation-cap"></i>
            </div>
            <div class="brand-text">
                <h1>Sipena (Anise App)</h1>
                <p>Smart Integrated School ERP & Character Habit System</p>
            </div>
        </div>
        <div class="badge-verified">
            <i class="ph-fill ph-check-circle"></i>
            <span>Google Play Live Demo Ready (No Login Required)</span>
        </div>
    </header>

    <!-- MAIN WORKSPACE -->
    <main class="workspace">
        
        <!-- CONTROL PANEL -->
        <div class="control-panel">
            <span class="hero-tag"><i class="ph ph-shield-check"></i> Play Store Reviewer Portal</span>
            <h2 class="hero-title">Live Preview Tanpa Otentikasi</h2>
            <p class="hero-desc">
                Sesuai dengan pedoman evaluasi Google Play Console, Anda dapat menjelajahi seluruh alur 17 modul dan 7 hak akses hierarki sekolah secara langsung melalui simulator di samping tanpa memerlukan login akun.
            </p>

            <div class="role-selector-title">
                <i class="ph-bold ph-users-three"></i> Pilih Peran Simulasi (Interactive Switcher)
            </div>

            <div class="role-cards">
                <!-- Siswa -->
                <div class="role-card active" onclick="switchRole('siswa')">
                    <div class="role-card-left">
                        <div class="role-icon"><i class="ph-bold ph-student"></i></div>
                        <div class="role-info">
                            <h4>Siswa (Murid)</h4>
                            <p>Presensi GPS, 7 Karakter Pembiasaan, Jadwal, Tugas</p>
                        </div>
                    </div>
                    <i class="ph-bold ph-caret-right" style="color: #64748b;"></i>
                </div>

                <!-- Guru Mapel & Wali -->
                <div class="role-card" onclick="switchRole('guru')">
                    <div class="role-card-left">
                        <div class="role-icon"><i class="ph-bold ph-chalkboard-teacher"></i></div>
                        <div class="role-info">
                            <h4>Guru Pengajar & Wali Kelas</h4>
                            <p>Jurnal KBM, Rekap Absensi Kelas, Monitoring Ibadah</p>
                        </div>
                    </div>
                    <i class="ph-bold ph-caret-right" style="color: #64748b;"></i>
                </div>

                <!-- Guru BK -->
                <div class="role-card" onclick="switchRole('bk')">
                    <div class="role-card-left">
                        <div class="role-icon"><i class="ph-bold ph-chats-circle"></i></div>
                        <div class="role-info">
                            <h4>Guru Bimbingan Konseling (BK)</h4>
                            <p>Konseling Siswa, Poin Disiplin & Pelanggaran, Surat Panggilan</p>
                        </div>
                    </div>
                    <i class="ph-bold ph-caret-right" style="color: #64748b;"></i>
                </div>

                <!-- Tata Usaha -->
                <div class="role-card" onclick="switchRole('tu')">
                    <div class="role-card-left">
                        <div class="role-icon"><i class="ph-bold ph-files"></i></div>
                        <div class="role-info">
                            <h4>Tata Usaha (TU)</h4>
                            <p>Manajemen Master Data Siswa/Guru, Pengaduan, Inventaris</p>
                        </div>
                    </div>
                    <i class="ph-bold ph-caret-right" style="color: #64748b;"></i>
                </div>

                <!-- Kepala Sekolah -->
                <div class="role-card" onclick="switchRole('kepsek')">
                    <div class="role-card-left">
                        <div class="role-icon"><i class="ph-bold ph-briefcase"></i></div>
                        <div class="role-info">
                            <h4>Kepala Sekolah</h4>
                            <p>Eksekutif Monitoring, Evaluasi KPI Tendik, Rekapitulasi</p>
                        </div>
                    </div>
                    <i class="ph-bold ph-caret-right" style="color: #64748b;"></i>
                </div>
            </div>

            <div class="play-notice">
                <i class="ph-fill ph-info" style="color: #38bdf8; margin-right: 4px;"></i>
                <strong>Catatan Reviewer:</strong> Versi binary native Android (.aab / .apk) telah ditandatangani dengan keystore produksi dan siap diterbitkan ke Google Play Store.
            </div>
        </div>

        <!-- RIGHT PHONE FRAME -->
        <div class="phone-wrapper">
            <div class="phone-frame">
                <!-- Notch -->
                <div class="phone-notch">
                    <div class="camera-lens"></div>
                </div>

                <!-- Screen -->
                <div class="screen-container">
                    
                    <!-- Mobile Status Bar -->
                    <div class="mobile-statusbar">
                        <span id="clockDisplay">07:45</span>
                        <div class="status-icons">
                            <i class="ph-fill ph-wifi-high"></i>
                            <i class="ph-fill ph-cell-signal-full"></i>
                            <i class="ph-fill ph-battery-charging"></i>
                        </div>
                    </div>

                    <!-- Mobile Header Bar -->
                    <div class="mobile-header">
                        <div class="user-greeting">
                            <div class="user-avatar-circle" id="userAvatar">M</div>
                            <div class="user-meta">
                                <h3 id="userName">Murid Siswa!!</h3>
                                <p id="userSub">NISN: 01 • Kelas X RPL 1</p>
                                <span class="role-pill" id="userRolePill">SISWA</span>
                            </div>
                        </div>
                        <i class="ph ph-bell-simple" style="font-size: 20px; color: #64748b; cursor: pointer;"></i>
                    </div>

                    <!-- Screen Body -->
                    <div class="screen-body" id="screenBody">
                        <!-- Dynamic Content injected via JS -->
                    </div>

                    <!-- Bottom Nav -->
                    <div class="mobile-bottom-nav">
                        <button class="nav-btn active" onclick="switchTab('home')">
                            <i class="ph-fill ph-house"></i>
                            <span>Beranda</span>
                        </button>
                        <button class="nav-btn" onclick="switchTab('jadwal')">
                            <i class="ph-bold ph-calendar"></i>
                            <span>Jadwal</span>
                        </button>
                        <button class="nav-btn" onclick="switchTab('pembiasaan')">
                            <i class="ph-bold ph-check-square"></i>
                            <span>Aktivitas</span>
                        </button>
                        <button class="nav-btn" onclick="switchTab('profil')">
                            <i class="ph-bold ph-user"></i>
                            <span>Profil</span>
                        </button>
                    </div>

                </div>
            </div>
        </div>

    </main>

    <!-- FOOTER -->
    <footer class="demo-footer">
        &copy; 2026 Helvetecha Group &bull; Sipena / Anise App Enterprise Ecosystem &bull; Google Play Compliance Release v1.0
    </footer>

    <!-- INTERACTIVE JAVASCRIPT LOGIC -->
    <script>
        // State
        let currentRole = 'siswa';
        let currentTab = 'home';

        // Data Definition for Roles
        const roleData = {
            siswa: {
                name: "Andi Wijaya!!",
                sub: "NISN: 0088497665 • Kelas X RPL 1",
                role: "SISWA",
                avatar: "A",
                bannerTitle: "Presensi Mandiri GPS Hari Ini",
                bannerDesc: "Radius Sekolah Valid (12 meter). Foto selfie terverifikasi AI.",
                bannerTag: "07:15 WIB • TEPAT WAKTU",
                widgets: [
                    { icon: "ph-check-circle", color: "icon-green", title: "Bangun Pagi & Subuh", sub: "Tervalidasi Mandiri", badge: "Selesai", bColor: "badge-success" },
                    { icon: "ph-book-open", color: "icon-blue", title: "Matematika Diskrit", sub: "08:00 - 09:30 • Ruang Lab 2", badge: "Mendatang", bColor: "badge-info" },
                    { icon: "ph-heartbeat", color: "icon-purple", title: "Olahraga Pagi", sub: "Target 15 Menit", badge: "Selesai", bColor: "badge-success" },
                    { icon: "ph-shield-warning", color: "icon-amber", title: "Poin Kedisiplinan", sub: "0 Pelanggaran Aktif", badge: "100 Poin", bColor: "badge-success" }
                ],
                showHabitBox: true
            },
            guru: {
                name: "Bpk. Rahmat, S.Pd!!",
                sub: "NUPTK: 1987111202211003 • Guru Mapel",
                role: "GURU PENGAJAR",
                avatar: "R",
                bannerTitle: "Jurnal Mengajar Aktif",
                bannerDesc: "Kelas X RPL 1 - Algoritma Pemrograman (Jam ke-1 & 2)",
                bannerTag: "STATUS: SEDANG BERLANGSUNG",
                widgets: [
                    { icon: "ph-users-four", color: "icon-blue", title: "Presensi X RPL 1", sub: "36 Siswa Hadir, 0 Sakit, 0 Alfa", badge: "Lengkap", bColor: "badge-success" },
                    { icon: "ph-pencil-line", color: "icon-purple", title: "Tugas Proyek Modul 3", sub: "28/36 Siswa Mengumpulkan", badge: "Perlu Dinilai", bColor: "badge-pending" },
                    { icon: "ph-calendar-check", color: "icon-green", title: "Jadwal Mengajar Berikutnya", sub: "XI MIPA 2 • 10:15 WIB", badge: "Siap", bColor: "badge-info" }
                ],
                showHabitBox: false
            },
            bk: {
                name: "Ibu Wartono, S.Psi!!",
                sub: "NUPTK: 199209092023211014 • Guru BK",
                role: "GURU BK",
                avatar: "W",
                bannerTitle: "Pusat Layanan Konseling",
                bannerDesc: "Monitoring Pembinaan Karakter & Penanganan Masalah Siswa",
                bannerTag: "2 PERMOHONAN BARU",
                widgets: [
                    { icon: "ph-chats", color: "icon-purple", title: "Konseling Karir & Kuliah", sub: "Siswa: Siti Rahma (XII RPL)", badge: "Hari Ini 13:00", bColor: "badge-info" },
                    { icon: "ph-warning-octagon", color: "icon-rose", title: "Laporan Keterlambatan", sub: "Rekap 3 Siswa Telat Pagi Ini", badge: "Diproses", bColor: "badge-pending" },
                    { icon: "ph-envelope-simple", color: "icon-amber", title: "Surat Panggilan Orang Tua", sub: "Arsip 2 Surat Terkirim", badge: "Terkirim", bColor: "badge-success" }
                ],
                showHabitBox: false
            },
            tu: {
                name: "Tata Usaha Sekolah!!",
                sub: "NIP: 000000000000001 • Administrasi",
                role: "TATA USAHA",
                avatar: "T",
                bannerTitle: "Sistem Administrasi Terpadu",
                bannerDesc: "Sinkronisasi Master Rombel, Arsip Siswa, & Inventaris Sarpras",
                bannerTag: "DATABASE BERSIH (PROD)",
                widgets: [
                    { icon: "ph-student", color: "icon-blue", title: "Master Siswa & Rombel", sub: "381 Siswa Terdaftar di Kelas", badge: "Sinkron", bColor: "badge-success" },
                    { icon: "ph-package", color: "icon-green", title: "Sarana & Prasarana", sub: "Peminjaman Lab & Proyektor", badge: "0 Tertunda", bColor: "badge-success" },
                    { icon: "ph-chat-teardrop-dots", color: "icon-amber", title: "Pengaduan & Aspirasi Siswa", sub: "Semua Laporan Ditindaklanjuti", badge: "Tuntas", bColor: "badge-success" }
                ],
                showHabitBox: false
            },
            kepsek: {
                name: "Drs. H. Mulyadi, M.Pd!!",
                sub: "NIP: 196803151994031005 • Kepala Sekolah",
                role: "KEPALA SEKOLAH",
                avatar: "M",
                bannerTitle: "Executive School Dashboard",
                bannerDesc: "Tingkat Kehadiran Guru: 98.4% &bull; Kehadiran Siswa: 97.8%",
                bannerTag: "PERFORMA: OPTIMAL",
                widgets: [
                    { icon: "ph-chart-line-up", color: "icon-green", title: "Evaluasi KPI Tendik", sub: "36 Guru Memenuhi Indikator", badge: "Grade A", bColor: "badge-success" },
                    { icon: "ph-clock-countdown", color: "icon-blue", title: "Kedisiplinan & Jam KBM", sub: "Tingkat Keterlambatan: 0.8%", badge: "Sangat Baik", bColor: "badge-success" },
                    { icon: "ph-file-pdf", color: "icon-purple", title: "Laporan Bulanan Dinas", sub: "Dokumen Semester Ganjil 2026/2027", badge: "Siap Cetak", bColor: "badge-info" }
                ],
                showHabitBox: false
            }
        };

        // Render UI
        function renderScreen() {
            const data = roleData[currentRole];
            
            // Header
            document.getElementById('userName').textContent = data.name;
            document.getElementById('userSub').textContent = data.sub;
            document.getElementById('userRolePill').textContent = data.role;
            document.getElementById('userAvatar').textContent = data.avatar;

            const body = document.getElementById('screenBody');
            body.innerHTML = '';

            if (currentTab === 'home') {
                // Quick Banner
                let bannerHtml = `
                    <div class="quick-banner">
                        <h4>${data.bannerTitle}</h4>
                        <p>${data.bannerDesc}</p>
                        <span class="quick-badge-time"><i class="ph-bold ph-shield-check"></i> ${data.bannerTag}</span>
                    </div>
                `;

                // Habit Progress Box (if Siswa)
                let habitHtml = '';
                if (data.showHabitBox) {
                    habitHtml = `
                        <div class="habit-progress-box">
                            <div class="habit-title-row">
                                <span>7 Pilar Pembiasaan Harian</span>
                                <span style="color: #059669;">6 / 7 Selesai</span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill"></div>
                            </div>
                            <p style="font-size: 11px; color: #64748b;">Menunggu: Evaluasi Belajar Malam</p>
                        </div>
                    `;
                }

                // Section Header
                let sectionTitle = `
                    <div class="section-header">
                        <h5>Aktivitas & Modul Utama</h5>
                        <a href="#">Semua (${data.widgets.length})</a>
                    </div>
                `;

                // Widgets list
                let widgetsHtml = '';
                data.widgets.forEach(w => {
                    widgetsHtml += `
                        <div class="widget-card">
                            <div class="widget-left">
                                <div class="widget-icon ${w.color}">
                                    <i class="ph-bold ${w.icon}"></i>
                                </div>
                                <div class="widget-text">
                                    <h6>${w.title}</h6>
                                    <p>${w.sub}</p>
                                </div>
                            </div>
                            <span class="widget-badge ${w.bColor}">${w.badge}</span>
                        </div>
                    `;
                });

                body.innerHTML = bannerHtml + habitHtml + sectionTitle + widgetsHtml;

            } else if (currentTab === 'jadwal') {
                body.innerHTML = `
                    <div class="section-header">
                        <h5>Jadwal Akademik Hari Ini</h5>
                        <span style="font-size: 11px; color: #2563eb; font-weight: 700;">Kamis, 29 Okt 2026</span>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-blue"><i class="ph-bold ph-clock"></i></div>
                            <div class="widget-text">
                                <h6>07:30 - 09:00 WIB</h6>
                                <p>Matematika Diskrit &bull; R. Lab 2</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-success">Selesai</span>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-amber"><i class="ph-bold ph-clock"></i></div>
                            <div class="widget-text">
                                <h6>09:15 - 11:30 WIB</h6>
                                <p>Pemrograman Berorientasi Objek</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-pending">Berlangsung</span>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-purple"><i class="ph-bold ph-clock"></i></div>
                            <div class="widget-text">
                                <h6>12:30 - 14:00 WIB</h6>
                                <p>Pendidikan Agama & Budi Pekerti</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-info">Berikutnya</span>
                    </div>
                `;
            } else if (currentTab === 'pembiasaan') {
                body.innerHTML = `
                    <div class="section-header">
                        <h5>Monitoring 7 Pilar Karakter</h5>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-green"><i class="ph-bold ph-sun"></i></div>
                            <div class="widget-text">
                                <h6>1. Bangun Pagi</h6>
                                <p>Tercatat: 04:45 WIB</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-success">Verifikasi</span>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-green"><i class="ph-bold ph-hands-praying"></i></div>
                            <div class="widget-text">
                                <h6>2. Ibadah Wajib</h6>
                                <p>Subuh Berjamaah & Dzuhur</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-success">Verifikasi</span>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-green"><i class="ph-bold ph-barbell"></i></div>
                            <div class="widget-text">
                                <h6>3. Olahraga Teratur</h6>
                                <p>Senam Pagi Sekolah</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-success">Verifikasi</span>
                    </div>
                    <div class="widget-card">
                        <div class="widget-left">
                            <div class="widget-icon icon-blue"><i class="ph-bold ph-book-bookmark"></i></div>
                            <div class="widget-text">
                                <h6>4. Gemar Belajar</h6>
                                <p>Literasi Perpustakaan Digital</p>
                            </div>
                        </div>
                        <span class="widget-badge badge-success">Verifikasi</span>
                    </div>
                `;
            } else if (currentTab === 'profil') {
                body.innerHTML = `
                    <div style="background: #ffffff; border-radius: 18px; padding: 20px; border: 1px solid #e2e8f0; text-align: center;">
                        <div class="user-avatar-circle" style="width: 64px; height: 64px; font-size: 24px; margin: 0 auto 12px;">${data.avatar}</div>
                        <h4 style="font-size: 16px; font-weight: 700; color: #0f172a;">${data.name.replace('!!', '')}</h4>
                        <p style="font-size: 12px; color: #64748b; margin-bottom: 8px;">${data.sub}</p>
                        <span class="role-pill">${data.role}</span>
                    </div>

                    <div class="widget-card" style="cursor: pointer;">
                        <div class="widget-left">
                            <div class="widget-icon icon-blue"><i class="ph-bold ph-shield-check"></i></div>
                            <div class="widget-text">
                                <h6>Keamanan & Sandi</h6>
                                <p>Terverifikasi Signature Hash</p>
                            </div>
                        </div>
                        <i class="ph-bold ph-caret-right" style="color: #94a3b8;"></i>
                    </div>

                    <div class="widget-card" style="cursor: pointer;">
                        <div class="widget-left">
                            <div class="widget-icon icon-purple"><i class="ph-bold ph-fingerprint"></i></div>
                            <div class="widget-text">
                                <h6>Biometrik & Pengenalan Wajah</h6>
                                <p>Tersimpan Lokal Aman</p>
                            </div>
                        </div>
                        <i class="ph-bold ph-caret-right" style="color: #94a3b8;"></i>
                    </div>

                    <div class="widget-card" style="cursor: pointer;">
                        <div class="widget-left">
                            <div class="widget-icon icon-green"><i class="ph-bold ph-question"></i></div>
                            <div class="widget-text">
                                <h6>Bantuan & Layanan WhatsApp</h6>
                                <p>Developer Support 24/7</p>
                            </div>
                        </div>
                        <i class="ph-bold ph-caret-right" style="color: #94a3b8;"></i>
                    </div>
                `;
            }
        }

        // Switch Role Handler
        function switchRole(roleKey) {
            currentRole = roleKey;
            currentTab = 'home';
            
            // Update active role card UI
            document.querySelectorAll('.role-card').forEach(card => card.classList.remove('active'));
            event.currentTarget.classList.add('active');

            // Reset tab button UI
            document.querySelectorAll('.nav-btn').forEach((btn, idx) => {
                if (idx === 0) btn.classList.add('active');
                else btn.classList.remove('active');
            });

            renderScreen();
        }

        // Switch Tab Handler
        function switchTab(tabKey) {
            currentTab = tabKey;
            document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
            event.currentTarget.classList.add('active');
            renderScreen();
        }

        // Clock updater
        function updateClock() {
            const now = new Date();
            const h = String(now.getHours()).padStart(2, '0');
            const m = String(now.getMinutes()).padStart(2, '0');
            document.getElementById('clockDisplay').textContent = `${h}:${m}`;
        }
        setInterval(updateClock, 1000);
        updateClock();

        // Initial render
        renderScreen();
    </script>
</body>
</html>
