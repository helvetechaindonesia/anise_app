<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anise Smart Education • Project Retrospective & Mission Control</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <style>
        :root {
            --bg: #090D16;
            --surface: #111827;
            --surface-card: rgba(17, 24, 39, 0.7);
            --border: rgba(255, 255, 255, 0.08);
            --primary: #3B82F6;
            --primary-glow: rgba(59, 130, 246, 0.35);
            --accent-cyan: #06B6D4;
            --accent-emerald: #10B981;
            --accent-amber: #F59E0B;
            --accent-purple: #8B5CF6;
            --text-main: #F9FAFB;
            --text-muted: #9CA3AF;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background-color: var(--bg);
            color: var(--text-main);
            font-family: 'Plus Jakarta Sans', sans-serif;
            min-height: 100vh;
            overflow-x: hidden;
            background-image: 
                radial-gradient(circle at 15% 15%, rgba(59, 130, 246, 0.15), transparent 40%),
                radial-gradient(circle at 85% 85%, rgba(139, 92, 246, 0.12), transparent 45%),
                radial-gradient(circle at 50% 50%, rgba(6, 182, 212, 0.08), transparent 60%);
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 24px 60px;
        }

        /* Top Bar */
        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 28px;
            background: var(--surface-card);
            backdrop-filter: blur(16px);
            border: 1px solid var(--border);
            border-radius: 20px;
            margin-bottom: 36px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .brand-icon {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, #2563EB, #06B6D4);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 0 20px var(--primary-glow);
            font-size: 24px;
        }

        .brand-title {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(to right, #ffffff, #93C5FD);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .brand-subtitle {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .badge-live {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.3);
            border-radius: 30px;
            font-size: 13px;
            font-weight: 600;
            color: #34D399;
        }

        .pulse-dot {
            width: 8px;
            height: 8px;
            background: #10B981;
            border-radius: 50%;
            box-shadow: 0 0 12px #10B981;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 0.8; }
            50% { transform: scale(1.3); opacity: 1; }
            100% { transform: scale(0.95); opacity: 0.8; }
        }

        /* Hero Showcase */
        .hero-banner {
            position: relative;
            background: linear-gradient(135deg, rgba(30, 58, 138, 0.6) 0%, rgba(17, 24, 39, 0.95) 100%);
            border: 1px solid rgba(59, 130, 246, 0.3);
            border-radius: 28px;
            padding: 48px;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.4);
            margin-bottom: 32px;
        }

        .hero-banner::after {
            content: '';
            position: absolute;
            top: -50%;
            right: -10%;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.25) 0%, transparent 70%);
            pointer-events: none;
        }

        .hero-content {
            position: relative;
            z-index: 2;
            max-width: 800px;
        }

        .hero-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 16px;
            background: rgba(255, 215, 0, 0.12);
            border: 1px solid rgba(255, 215, 0, 0.3);
            border-radius: 20px;
            color: #FBBF24;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 20px;
        }

        .hero-title {
            font-size: 42px;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 16px;
            letter-spacing: -1px;
        }

        .hero-desc {
            font-size: 16px;
            line-height: 1.6;
            color: #CBD5E1;
            margin-bottom: 28px;
        }

        .hero-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
        }

        .meta-pill {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 18px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border);
            border-radius: 14px;
            font-size: 14px;
            font-weight: 600;
            color: #E2E8F0;
        }

        .meta-pill i {
            color: var(--primary);
            font-size: 18px;
        }

        /* Metric Grid */
        .grid-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 32px;
        }

        .card-stat {
            background: var(--surface-card);
            backdrop-filter: blur(12px);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 28px;
            position: relative;
            transition: all 0.3s ease;
        }

        .card-stat:hover {
            transform: translateY(-4px);
            border-color: rgba(255, 255, 255, 0.2);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.3);
        }

        .card-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 20px;
        }

        .icon-amber { background: rgba(245, 158, 11, 0.15); color: #F59E0B; }
        .icon-emerald { background: rgba(16, 185, 129, 0.15); color: #10B981; }
        .icon-purple { background: rgba(139, 92, 246, 0.15); color: #8B5CF6; }
        .icon-cyan { background: rgba(6, 182, 212, 0.15); color: #06B6D4; }

        .stat-value {
            font-size: 38px;
            font-weight: 800;
            letter-spacing: -1px;
            margin-bottom: 6px;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .stat-title {
            font-size: 14px;
            font-weight: 700;
            color: #E2E8F0;
            margin-bottom: 4px;
        }

        .stat-subtitle {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* Double Column Section */
        .layout-double {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
            margin-bottom: 32px;
        }

        .panel {
            background: var(--surface-card);
            backdrop-filter: blur(12px);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 32px;
        }

        .panel-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }

        .panel-header i {
            font-size: 24px;
            color: var(--primary);
        }

        .panel-title {
            font-size: 18px;
            font-weight: 800;
            letter-spacing: -0.3px;
        }

        /* Tech Badges */
        .badge-cloud {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .tech-pill {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border);
            border-radius: 14px;
            font-size: 13px;
            font-weight: 600;
            color: #CBD5E1;
            transition: all 0.2s ease;
        }

        .tech-pill:hover {
            background: rgba(59, 130, 246, 0.1);
            border-color: rgba(59, 130, 246, 0.3);
            color: #93C5FD;
        }

        .tech-pill i {
            font-size: 18px;
            color: var(--accent-cyan);
        }

        /* Role Breakdown */
        .role-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .role-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 18px;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border);
            border-radius: 12px;
        }

        .role-name {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            font-weight: 600;
        }

        .role-name i {
            color: var(--primary);
        }

        .role-status {
            font-size: 11px;
            font-weight: 700;
            color: #34D399;
            background: rgba(16, 185, 129, 0.1);
            padding: 4px 10px;
            border-radius: 20px;
        }

        /* Footer */
        .footer-tribute {
            text-align: center;
            padding: 32px 20px;
            background: var(--surface-card);
            border: 1px solid var(--border);
            border-radius: 20px;
        }

        .footer-quote {
            font-size: 15px;
            color: #CBD5E1;
            font-style: italic;
            margin-bottom: 12px;
        }

        .footer-brand {
            font-size: 13px;
            font-weight: 700;
            color: var(--primary);
            letter-spacing: 0.5px;
        }

        @media (max-width: 1024px) {
            .grid-stats { grid-template-columns: repeat(2, 1fr); }
            .layout-double { grid-template-columns: 1fr; }
            .hero-title { font-size: 32px; }
        }

        @media (max-width: 640px) {
            .grid-stats { grid-template-columns: 1fr; }
            .hero-banner { padding: 28px 20px; }
        }
    </style>
</head>
<body>

<div class="container">
    <!-- Topbar -->
    <header class="topbar">
        <div class="brand">
            <div class="brand-icon">
                <i class="ph-bold ph-graduation-cap"></i>
            </div>
            <div>
                <div class="brand-title">Anise Smart Education</div>
                <div class="brand-subtitle">Project Retrospective & Production Dashboard</div>
            </div>
        </div>
        <div class="badge-live">
            <div class="pulse-dot"></div>
            <span>PRODUCTION READY (28 OKTOBER 2026)</span>
        </div>
    </header>

    <!-- Hero Banner -->
    <section class="hero-banner">
        <div class="hero-content">
            <div class="hero-tag">
                <i class="ph-fill ph-trophy"></i>
                <span>SPRINT MASTERPIECE • VELOCITY GRADE S</span>
            </div>
            <h1 class="hero-title">Perjalanan Pembangunan: 57 Hari Dedikasi Arsitektur</h1>
            <p class="hero-desc">
                Folder proyek ini pertama kali lahir di filesystem PC pada <strong>Selasa, 01 September 2026 pukul 03:57 WIB</strong>. Dilanjutkan dengan fase demo & sprint maraton intensif (01 - 28 Oktober 2026) hingga mencapai tahap <em>Production Ready</em> dan siap rilis Play Store.
            </p>
            <div class="hero-meta">
                <div class="meta-pill">
                    <i class="ph-bold ph-hard-drives"></i>
                    <span>Inisiasi Folder PC: 01 Sep 2026</span>
                </div>
                <div class="meta-pill">
                    <i class="ph-bold ph-calendar"></i>
                    <span>Sprint Git: 01 Okt - 28 Okt 2026</span>
                </div>
                <div class="meta-pill">
                    <i class="ph-bold ph-rocket-launch"></i>
                    <span>Rilis Resmi: 02 Nov 2026</span>
                </div>
                <div class="meta-pill">
                    <i class="ph-bold ph-code"></i>
                    <span>Team: Helvetecha Engineering</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Grid Metric Stats -->
    <section class="grid-stats">
        <div class="card-stat">
            <div class="card-icon icon-amber">
                <i class="ph-fill ph-clock-countdown"></i>
            </div>
            <div class="stat-value">57 Hari</div>
            <div class="stat-title">Total Siklus Hidup Proyek</div>
            <div class="stat-subtitle">Terhitung sejak folder dibuat (01 Sep 2026)</div>
        </div>

        <div class="card-stat">
            <div class="card-icon icon-emerald">
                <i class="ph-fill ph-git-commit"></i>
            </div>
            <div class="stat-value">379 Commit</div>
            <div class="stat-title">Total Jejak Iterasi Git</div>
            <div class="stat-subtitle">Fase sprint cepat 27 hari (rata-rata 14/hari)</div>
        </div>

        <div class="card-stat">
            <div class="card-icon icon-purple">
                <i class="ph-fill ph-lightning"></i>
            </div>
            <div class="stat-value">95.2 / 100</div>
            <div class="stat-title">Velocity & Quality Score</div>
            <div class="stat-subtitle">Standar industri arsitektur enterprise</div>
        </div>

        <div class="card-stat">
            <div class="card-icon icon-cyan">
                <i class="ph-fill ph-users-three"></i>
            </div>
            <div class="stat-value">7 Role</div>
            <div class="stat-title">Ekosistem Multi-Tenant</div>
            <div class="stat-subtitle">Siswa, Pengajar, Wali, BK, TU, Sarpras, Kepsek</div>
        </div>
    </section>

    <!-- Double Layout: Tech Stack & Role Breakdown -->
    <section class="layout-double">
        <div class="panel">
            <div class="panel-header">
                <i class="ph-bold ph-stack"></i>
                <div class="panel-title">Teknologi & Arsitektur Utama</div>
            </div>
            <div class="badge-cloud">
                <div class="tech-pill"><i class="ph-bold ph-device-mobile"></i> Flutter Multiplatform Frontend</div>
                <div class="tech-pill"><i class="ph-bold ph-server"></i> Laravel 11 RESTful Backend</div>
                <div class="tech-pill"><i class="ph-bold ph-database"></i> PostgreSQL Relational Engine</div>
                <div class="tech-pill"><i class="ph-bold ph-map-pin"></i> GPS Geofencing Precision Presensi</div>
                <div class="tech-pill"><i class="ph-bold ph-user-focus"></i> Biometrik Wajah 3D Mesh (Anti-Fraud)</div>
                <div class="tech-pill"><i class="ph-bold ph-heartbeat"></i> Realtime Session Heartbeat & Security</div>
                <div class="tech-pill"><i class="ph-bold ph-whatsapp-logo"></i> Self-Hosted WA Gateway (Baileys)</div>
                <div class="tech-pill"><i class="ph-bold ph-calendar-check"></i> Virtual Server Time (Time Travel Sync)</div>
                <div class="tech-pill"><i class="ph-bold ph-google-play-logo"></i> Google Play SDK 35/36 Compliant</div>
                <div class="tech-pill"><i class="ph-bold ph-shield-check"></i> Full Privacy Policy & Data Deletion Flow</div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <i class="ph-bold ph-shield-star"></i>
                <div class="panel-title">Multi-Role Terintegrasi</div>
            </div>
            <div class="role-list">
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-student"></i> Siswa / Murid</div>
                    <div class="role-status">Verified Active</div>
                </div>
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-chalkboard-teacher"></i> Guru Mata Pelajaran</div>
                    <div class="role-status">Verified Active</div>
                </div>
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-user-check"></i> Guru Wali Kelas</div>
                    <div class="role-status">Verified Active</div>
                </div>
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-chats-circle"></i> Bimbingan Konseling (BK)</div>
                    <div class="role-status">Verified Active</div>
                </div>
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-buildings"></i> Tata Usaha (TU)</div>
                    <div class="role-status">Verified Active</div>
                </div>
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-wrench"></i> Tim Sarpras & Kesiswaan</div>
                    <div class="role-status">Verified Active</div>
                </div>
                <div class="role-item">
                    <div class="role-name"><i class="ph-bold ph-crown"></i> Kepala Sekolah</div>
                    <div class="role-status">Verified Active</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer Tribute -->
    <footer class="footer-tribute">
        <p class="footer-quote">"Setiap baris kode yang ditulis adalah manifestasi dari dedikasi tanpa henti untuk mentransformasi sistem pendidikan modern."</p>
        <p class="footer-brand">HELVETECHA ENGINEERING TEAM • ANISE SMART EDUCATION 2026</p>
    </footer>
</div>

</body>
</html>
