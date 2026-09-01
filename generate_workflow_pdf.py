import os
import sys
import subprocess

html_content = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>AstroDashaCare - Complete Application Workflow & Architecture Specification</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@500;700;900&family=Outfit:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap');

  @page {
    size: A4 portrait;
    margin: 14mm 16mm 16mm 16mm;
    @bottom-right {
      content: "Page " counter(page);
      font-family: 'Outfit', sans-serif;
      font-size: 8pt;
      color: #8892b0;
    }
  }

  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  body {
    font-family: 'Outfit', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background-color: #070B14;
    color: #E2E8F0;
    margin: 0;
    padding: 0;
    font-size: 9.5pt;
    line-height: 1.55;
  }

  .page-break {
    page-break-before: always;
    break-before: page;
    padding-top: 4mm;
  }

  .no-break {
    page-break-inside: avoid;
    break-inside: avoid;
  }

  /* Cover Page */
  .cover-container {
    height: 98vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 20px 10px;
    border: 2px solid #D4AF37;
    border-radius: 16px;
    background: radial-gradient(circle at 50% 20%, #1A173B 0%, #080D1A 60%, #03060D 100%);
    position: relative;
    box-shadow: inset 0 0 50px rgba(212, 175, 55, 0.15);
  }

  .cover-header {
    text-align: center;
    padding-top: 30px;
  }

  .cosmic-badge {
    display: inline-block;
    padding: 6px 18px;
    background: rgba(212, 175, 55, 0.12);
    border: 1px solid #D4AF37;
    border-radius: 30px;
    color: #FFD700;
    font-family: 'Outfit', sans-serif;
    font-size: 9pt;
    font-weight: 700;
    letter-spacing: 2.5px;
    text-transform: uppercase;
    margin-bottom: 20px;
  }

  .cover-title {
    font-family: 'Cinzel', serif;
    font-size: 30pt;
    font-weight: 900;
    color: #FFF6D6;
    text-transform: uppercase;
    letter-spacing: 3px;
    margin: 0;
    text-shadow: 0 0 25px rgba(255, 215, 0, 0.4);
    line-height: 1.15;
  }

  .cover-subtitle {
    font-family: 'Cinzel', serif;
    font-size: 14pt;
    color: #00F0FF;
    letter-spacing: 2px;
    margin-top: 12px;
    font-weight: 600;
  }

  .cover-tagline {
    font-size: 11pt;
    color: #94A3B8;
    max-width: 550px;
    margin: 18px auto 0;
    line-height: 1.6;
    font-weight: 300;
  }

  .cover-diagram {
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 30px 0;
  }

  .role-triad {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    width: 100%;
    max-width: 580px;
  }

  .triad-card {
    background: rgba(15, 23, 42, 0.75);
    border: 1px solid rgba(212, 175, 55, 0.4);
    border-radius: 12px;
    padding: 16px 12px;
    text-align: center;
  }

  .triad-icon {
    font-size: 24pt;
    margin-bottom: 6px;
    display: block;
  }

  .triad-title {
    font-family: 'Cinzel', serif;
    font-size: 11pt;
    font-weight: 700;
    color: #FFD700;
    margin-bottom: 4px;
  }

  .triad-desc {
    font-size: 8pt;
    color: #94A3B8;
    line-height: 1.35;
  }

  .cover-meta {
    background: rgba(10, 15, 29, 0.85);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    padding: 18px 24px;
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .meta-item {
    font-size: 8.5pt;
    color: #94A3B8;
  }

  .meta-item strong {
    color: #F8FAFC;
    font-weight: 600;
  }

  .cover-footer {
    text-align: center;
    font-size: 8pt;
    color: #64748B;
    padding-bottom: 10px;
    border-top: 1px solid rgba(255, 255, 255, 0.06);
    padding-top: 12px;
  }

  /* Document Typography */
  h1, h2, h3, h4 {
    font-family: 'Cinzel', serif;
    color: #FFD700;
    margin-top: 0;
    letter-spacing: 0.5px;
  }

  h1 {
    font-size: 16pt;
    border-bottom: 2px solid #D4AF37;
    padding-bottom: 6px;
    margin-bottom: 14px;
    text-transform: uppercase;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  h1 .section-num {
    font-family: 'Outfit', sans-serif;
    font-size: 10pt;
    background: rgba(212, 175, 55, 0.18);
    color: #FFD700;
    padding: 3px 10px;
    border-radius: 6px;
    border: 1px solid #D4AF37;
    font-weight: 700;
    letter-spacing: 1px;
  }

  h2 {
    font-size: 12.5pt;
    color: #00F0FF;
    margin-top: 16px;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  h3 {
    font-size: 10.5pt;
    color: #FFF6D6;
    margin-top: 12px;
    margin-bottom: 6px;
  }

  p {
    margin: 0 0 10px 0;
    color: #CBD5E1;
    text-align: justify;
  }

  /* Section Containers */
  .section-card {
    background: #0E1526;
    border: 1px solid rgba(212, 175, 55, 0.25);
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 14px;
  }

  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .grid-3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
  }

  .grid-4 {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
  }

  /* Flowchart / Step Boxes */
  .step-flow {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin: 12px 0;
  }

  .step-node {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    background: #131D33;
    border: 1px solid rgba(0, 240, 255, 0.2);
    border-radius: 8px;
    padding: 10px 14px;
  }

  .step-badge {
    background: linear-gradient(135deg, #D4AF37 0%, #AA7C11 100%);
    color: #050914;
    font-family: 'Outfit', sans-serif;
    font-weight: 800;
    font-size: 9pt;
    width: 26px;
    height: 26px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    margin-top: 2px;
  }

  .step-content h4 {
    margin: 0 0 3px 0;
    font-size: 9.5pt;
    color: #F8FAFC;
    font-family: 'Outfit', sans-serif;
    font-weight: 700;
  }

  .step-content p {
    margin: 0;
    font-size: 8.5pt;
    color: #94A3B8;
    line-height: 1.4;
  }

  .arrow-down {
    text-align: center;
    color: #D4AF37;
    font-size: 11pt;
    line-height: 1;
    margin: -3px 0;
  }

  /* Tables */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0;
    font-size: 8.5pt;
  }

  th {
    background: #18233C;
    color: #FFD700;
    font-family: 'Cinzel', serif;
    font-weight: 700;
    text-align: left;
    padding: 7px 10px;
    border: 1px solid rgba(212, 175, 55, 0.3);
    letter-spacing: 0.5px;
  }

  td {
    padding: 6px 10px;
    border: 1px solid rgba(255, 255, 255, 0.07);
    color: #CBD5E1;
    background: rgba(14, 21, 38, 0.6);
  }

  tr:nth-child(even) td {
    background: rgba(19, 29, 51, 0.7);
  }

  .badge {
    display: inline-block;
    padding: 2px 7px;
    border-radius: 4px;
    font-size: 7.5pt;
    font-weight: 700;
    font-family: 'JetBrains Mono', monospace;
    text-transform: uppercase;
  }

  .badge-gold { background: rgba(212, 175, 55, 0.2); color: #FFD700; border: 1px solid rgba(212, 175, 55, 0.4); }
  .badge-cyan { background: rgba(0, 240, 255, 0.15); color: #00F0FF; border: 1px solid rgba(0, 240, 255, 0.3); }
  .badge-purple { background: rgba(138, 43, 226, 0.2); color: #C084FC; border: 1px solid rgba(138, 43, 226, 0.4); }
  .badge-green { background: rgba(34, 197, 94, 0.15); color: #4ADE80; border: 1px solid rgba(34, 197, 94, 0.3); }
  .badge-red { background: rgba(239, 68, 68, 0.15); color: #F87171; border: 1px solid rgba(239, 68, 68, 0.3); }

  /* Callout box */
  .callout {
    border-left: 4px solid #D4AF37;
    background: rgba(212, 175, 55, 0.08);
    padding: 10px 14px;
    border-radius: 0 8px 8px 0;
    margin: 10px 0;
    font-size: 8.5pt;
  }

  .callout strong {
    color: #FFD700;
  }

  .callout-cyan {
    border-left-color: #00F0FF;
    background: rgba(0, 240, 255, 0.08);
  }
  .callout-cyan strong { color: #00F0FF; }

  .callout-purple {
    border-left-color: #8A2BE2;
    background: rgba(138, 43, 226, 0.08);
  }
  .callout-purple strong { color: #C084FC; }

  /* Module card */
  .module-card {
    background: #111A2E;
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 8px;
    padding: 10px 12px;
  }

  .module-card-title {
    font-family: 'Cinzel', serif;
    font-size: 9.5pt;
    font-weight: 700;
    color: #FFD700;
    margin-bottom: 4px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .module-card-sub {
    font-size: 8pt;
    color: #94A3B8;
    margin-bottom: 6px;
  }

  .module-card-list {
    margin: 0;
    padding-left: 16px;
    font-size: 8pt;
    color: #CBD5E1;
  }

  .module-card-list li {
    margin-bottom: 3px;
  }

  /* Code / Monospace */
  code {
    font-family: 'JetBrains Mono', monospace;
    font-size: 8pt;
    background: #1A2236;
    color: #00F0FF;
    padding: 1px 5px;
    border-radius: 4px;
    border: 1px solid rgba(255,255,255,0.08);
  }

  /* Header & Footer in Body */
  .doc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(212, 175, 55, 0.3);
    padding-bottom: 5px;
    margin-bottom: 12px;
    font-size: 8pt;
    color: #8892b0;
    font-family: 'Cinzel', serif;
  }

  .doc-header .app-brand {
    color: #FFD700;
    font-weight: 700;
  }

</style>
</head>
<body>

<!-- ========================================================================= -->
<!-- COVER PAGE -->
<!-- ========================================================================= -->
<div class="cover-container">
  <div class="cover-header">
    <div class="cosmic-badge">✨ ENTERPRISE VEDIC ARCHITECTURE ✨</div>
    <div class="cover-title">AstroDashaCare</div>
    <div class="cover-subtitle">Digital Consulting Center & Astrological Computing Engine</div>
    <div class="cover-tagline">
      Comprehensive End-to-End Application Workflow, Architectural Blueprint, Engine Specifications & Technical Guide
    </div>
  </div>

  <div class="cover-diagram">
    <div class="role-triad">
      <div class="triad-card">
        <span class="triad-icon">👤</span>
        <div class="triad-title">User Journey</div>
        <div class="triad-desc">Kundli Generation, 20+ Astrological Engines, AI Guru, Live Consultations, Astro E-Commerce & Digital Wallet.</div>
      </div>
      <div class="triad-card">
        <span class="triad-icon">🔮</span>
        <div class="triad-title">Astrologer Portal</div>
        <div class="triad-desc">Call Queue Management, Live Native HUD & Kundli Viewer, Per-Minute Tariff, Break Timers & Wallet Earnings.</div>
      </div>
      <div class="triad-card">
        <span class="triad-icon">🛡️</span>
        <div class="triad-title">Admin Control</div>
        <div class="triad-desc">Astrologer Approvals, Multi-CMS (Panchang, Ephemeris, Terms, Magazine), Mundane Global Analytics & RBAC.</div>
      </div>
    </div>
  </div>

  <div>
    <div class="cover-meta">
      <div class="meta-item"><strong>Platform:</strong> Flutter Multi-Platform (Android / iOS / Web / Desktop)</div>
      <div class="meta-item"><strong>Backend API:</strong> Python 3 FastAPI + MongoDB (with Persistent Storage Fallback)</div>
      <div class="meta-item"><strong>Astrology Algorithms:</strong> Lahiri Ephemeris, KP System, BNN, Jamakol, Siddha Panchapakshi</div>
      <div class="meta-item"><strong>Document Type:</strong> System Architecture & Operational Workflow Manual</div>
      <div class="meta-item"><strong>Version:</strong> 2.0.0 Enterprise Release</div>
      <div class="meta-item"><strong>Security & RBAC:</strong> JWT Token Auth, Guarded Role Routes, Dynamic Session Guard</div>
    </div>
  </div>

  <div class="cover-footer">
    AstroDashaCare Digital Consulting Center • Generated for System Stakeholders & Development Team • Strictly Confidential
  </div>
</div>

<!-- ========================================================================= -->
<!-- SECTION 1: EXECUTIVE SUMMARY & SYSTEM ARCHITECTURE -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 1 • System Architecture</span>
</div>

<h1>
  1. Executive Summary & System Architecture
  <span class="section-num">SYSTEM DESIGN</span>
</h1>

<p>
  <strong>AstroDashaCare (Astrocall)</strong> is an enterprise-grade digital astrological ecosystem combining ancient Vedic, Nadi, KP, and Tamil Siddha computational systems with modern real-time consulting, AI assistance, and commerce. The platform operates on a reactive multi-tier architecture enabling high-precision astronomical calculations alongside secure tele-consultations.
</p>

<div class="section-card">
  <h2>🏛️ High-Level Multi-Tier Architectural Topology</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 22%;">Layer</th>
        <th style="width: 38%;">Technologies & Components</th>
        <th style="width: 40%;">Core Responsibilities</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><span class="badge badge-gold">Presentation Layer</span></td>
        <td>Flutter 3.x, Dart 3.11+, Google Fonts (Cinzel/Outfit), Flutter Animate, Shimmer, Svg</td>
        <td>Reactive Glassmorphic UI, responsive layouts for Mobile/Web, real-time animation HUDs, South/North Indian chart renderers.</td>
      </tr>
      <tr>
        <td><span class="badge badge-cyan">Client Computing</span></td>
        <td>Dart Math Engines, Geocoding Database (10,000+ cities), Offline Ephemeris, PDF/Printing</td>
        <td>Zero-latency calculation of 20+ astrological methods (SAV, KP Cusps, BNN, Horary, Panchapakshi), on-device PDF generation.</td>
      </tr>
      <tr>
        <td><span class="badge badge-purple">Backend Service</span></td>
        <td>Python 3 FastAPI, Pydantic, Uvicorn, CORS Middleware, RESTful API Suite</td>
        <td>Centralized authentication, role verification, consultation signaling, CMS data ingestion, wallet billing, and database transactions.</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">Persistence Layer</span></td>
        <td>MongoDB Server (Production) + Mongomock with JSON File Sync (Offline Fallback)</td>
        <td>ACID transactions for user profiles, astrologer verification records, magazine feeds, custom panchang, and wallet ledger.</td>
      </tr>
    </tbody>
  </table>
</div>

<div class="grid-2">
  <div class="section-card">
    <h2>🎯 The Three User Personas</h2>
    <div class="step-flow">
      <div class="step-node">
        <div class="step-badge">1</div>
        <div class="step-content">
          <h4>Client / Seeker (Role: User)</h4>
          <p>Accesses daily horoscopes, personal kundli, 20+ calculation engines, AI assistant, joins call queues, buys spiritual products, and pays via wallet.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">2</div>
        <div class="step-content">
          <h4>Certified Astrologer (Role: Astrologer)</h4>
          <p>Manages live availability, sets per-minute consultation tariffs, takes voice/video calls with live client kundli overlay, tracks payouts.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">3</div>
        <div class="step-content">
          <h4>Platform Administrator (Role: Admin)</h4>
          <p>Monitors system metrics, audits astrologer KYC/credentials, manages Panchang & Ephemeris CMS, edits T&C, and runs Mundane analytics.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="section-card">
    <h2>🛡️ Security & Role-Based Access Control (RBAC)</h2>
    <p>
      The application enforces strict Route Guards (<code>_guardedRoute</code> in <code>main.dart</code>) and API authorization:
    </p>
    <ul class="module-card-list">
      <li><strong>Admin Lockdown:</strong> Routes <code>/admin_dashboard</code>, <code>/admin_panchang</code>, <code>/admin_planet_positions</code>, <code>/mundane_astrology</code> reject non-admin sessions.</li>
      <li><strong>Astrologer Gate:</strong> <code>/astrologer_dashboard</code> requires verified Astrologer credentials.</li>
      <li><strong>Anti-Contact Policy:</strong> Phone numbers & bank data obfuscated during live sessions to protect platform integrity.</li>
      <li><strong>Grace Refund:</strong> Disconnections &lt; 60s trigger automatic full wallet refunds.</li>
    </ul>
  </div>
</div>

<!-- ========================================================================= -->
<!-- SECTION 2: END-TO-END USER (CLIENT) WORKFLOW -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 2 • Client Workflow</span>
</div>

<h1>
  2. End-to-End User (Client) Workflow
  <span class="section-num">USER EXPERIENCE</span>
</h1>

<p>
  The Client Journey is designed to be intuitive, cosmic, and friction-free, guiding users from onboarding to in-depth astrological analysis and consultations.
</p>

<div class="step-flow">
  <div class="step-node">
    <div class="step-badge">1</div>
    <div class="step-content">
      <h4>App Launch & Splash Cinematic (`SplashScreen`)</h4>
      <p>Initializes cosmic theme, loads persisted tokens from `AuthService`, preloads astrological constants, and routes to `/login` or `/user_dashboard` based on session state.</p>
    </div>
  </div>
  <div class="arrow-down">▼</div>

  <div class="step-node">
    <div class="step-badge">2</div>
    <div class="step-content">
      <h4>Multi-Factor Authentication & Role Choice (`LoginScreen`)</h4>
      <p>Users can authenticate via Mobile Number + OTP/Password, Google OAuth, or Demo Auto-login. User selects active profile role: <code>User</code>, <code>Astrologer</code>, or <code>Admin</code>.</p>
    </div>
  </div>
  <div class="arrow-down">▼</div>

  <div class="step-node">
    <div class="step-badge">3</div>
    <div class="step-content">
      <h4>Legal Terms & Astrological Disclaimer (`TermsConditionsScreen`)</h4>
      <p>First-time users accept dynamic terms fetched from backend CMS (privacy policy, consultation ethics, non-disclosure, wallet deduction rules).</p>
    </div>
  </div>
  <div class="arrow-down">▼</div>

  <div class="step-node">
    <div class="step-badge">4</div>
    <div class="step-content">
      <h4>Native Horoscope Profile Setup (`UserHoroscopeProfileScreen`)</h4>
      <p>Captures Name, Gender, Date of Birth (DOB), Time of Birth (TOB), and Place of Birth (POB). Integrated <code>GeocodingService</code> automatically resolves exact Latitude, Longitude, and Timezone offset.</p>
    </div>
  </div>
  <div class="arrow-down">▼</div>

  <div class="step-node">
    <div class="step-badge">5</div>
    <div class="step-content">
      <h4>Main User Dashboard Hub (`DashboardScreen`)</h4>
      <p>Presents a rich cosmic glassmorphic interface featuring: Live Panchang widget, 20+ Astrological Tool cards, Featured Astrologers carousel, Daily Zodiac Horoscopes, AI Assistant access, and Drawer navigation.</p>
    </div>
  </div>
</div>

<div class="section-card no-break">
  <h2>🌟 Client Functional Matrix & Interaction Paths</h2>
  <div class="grid-3">
    <div class="module-card">
      <div class="module-card-title"><span>🔭 Kundli & Analysis</span> <span class="badge badge-gold">CORE</span></div>
      <div class="module-card-sub">Birth Chart & Calculations</div>
      <p style="font-size: 8pt; color: #94A3B8;">Computes D1 Rasi, D9 Navamsha, Bhava Chalit, Vimshottari Dasha timeline, KP Cusps, BNN combinations, and Ashtakavarga matrices instantly.</p>
    </div>
    <div class="module-card">
      <div class="module-card-title"><span>📞 Live Consultation</span> <span class="badge badge-purple">LIVE</span></div>
      <div class="module-card-sub">Voice, Video & Chat</div>
      <p style="font-size: 8pt; color: #94A3B8;">Selects certified astrologers, checks per-minute rate, joins call queue, engages in consultation with live wallet deduction, and rates astrologer post-call.</p>
    </div>
    <div class="module-card">
      <div class="module-card-title"><span>🛍️ Shop & Wallet</span> <span class="badge badge-green">COMMERCE</span></div>
      <div class="module-card-sub">Remedies & Payments</div>
      <p style="font-size: 8pt; color: #94A3B8;">Purchases certified natural gemstones, energized Rudrakshas, Yantras, recharges AstroDashaCare Wallet via Razorpay/UPI, and manages PDF settings.</p>
    </div>
  </div>
</div>

<!-- ========================================================================= -->
<!-- SECTION 3: ASTROLOGER & ADMIN WORKFLOWS -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 3 • Astrologer & Admin Portals</span>
</div>

<h1>
  3. Astrologer Portal & Admin Control Workflows
  <span class="section-num">OPERATIONS</span>
</h1>

<div class="grid-2">
  <!-- ASTROLOGER WORKFLOW -->
  <div class="section-card">
    <h2>🔮 Astrologer Operational Flow</h2>
    <div class="step-flow">
      <div class="step-node">
        <div class="step-badge">1</div>
        <div class="step-content">
          <h4>Registration & Profile Verification</h4>
          <p>Submits bio, certifications, languages (Tamil, English, Hindi), experience years, specializations (Vedic, KP, Nadi, Jamakol), and desired per-minute rate.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">2</div>
        <div class="step-content">
          <h4>Admin Approval Gate</h4>
          <p>Account placed in <code>Pending</code> status until Admin reviews credentials and activates the profile in the live roster.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">3</div>
        <div class="step-content">
          <h4>Astrologer Dashboard (`AstrologerDashboardScreen`)</h4>
          <p>Controls live status: <code>Online</code>, <code>Busy</code>, or <code>Take Break</code> (with 5m/15m/30m countdown auto-revert).</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">4</div>
        <div class="step-content">
          <h4>Consultation HUD (`ConsultationScreen`)</h4>
          <p>Accepts incoming calls, displays client birth details, instant South Indian Rasi & Navamsha chart overlay, notes taker, and live earnings ticker.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">5</div>
        <div class="step-content">
          <h4>Earnings & Payout Ledger</h4>
          <p>Real-time calculation of consultation revenues, platform revenue-share breakdown, and withdrawal requests.</p>
        </div>
      </div>
    </div>
  </div>

  <!-- ADMIN WORKFLOW -->
  <div class="section-card">
    <h2>🛡️ Administrator Control Center</h2>
    <div class="step-flow">
      <div class="step-node">
        <div class="step-badge">1</div>
        <div class="step-content">
          <h4>Master Dashboard (`AdminDashboardScreen`)</h4>
          <p>Monitors high-level KPIs: Active Users, Verified Astrologers, Pending KYC Approvals, Total Consultations, and Platform Revenue.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">2</div>
        <div class="step-content">
          <h4>Astrologer Roster Management</h4>
          <p>Add new astrologers, edit tariffs/specializations, upload avatars via FilePicker, approve/reject/delete astrologer profiles.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">3</div>
        <div class="step-content">
          <h4>Daily Panchang CMS (`AdminPanchangCmsScreen`)</h4>
          <p>Overrides sunrise/sunset, Tithi, Nakshatra, Yoga, Karana, Rahu Kalam, Yamagandam, and festival dates for any given day.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">4</div>
        <div class="step-content">
          <h4>Planetary CMS & Terms CMS</h4>
          <p>Manages live ephemeris coordinates, retrogrades, and legal disclaimers/terms through dynamic in-app CMS.</p>
        </div>
      </div>
      <div class="step-node">
        <div class="step-badge">5</div>
        <div class="step-content">
          <h4>Mundane Astrology Monitor (`MundaneAstrologyScreen`)</h4>
          <p>Analyzes National Kundlis (e.g. India 15-Aug-1947), Mesha Sankranti Ingress, Eclipses, and Global Geopolitical trends.</p>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="callout callout-cyan no-break">
  <strong>🔒 Role Switching Feature:</strong> The platform includes a seamless Workspace Switcher in <code>CosmicDrawer</code> allowing authorized administrators and astrologers to switch between Client View, Astrologer Workspace, and Admin Control Center without re-logging.
</div>

<!-- ========================================================================= -->
<!-- SECTION 4: THE 20+ ASTROLOGICAL CALCULATION ENGINES -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 4 • Calculation Engines</span>
</div>

<h1>
  4. Core Astrological Engines & Calculation Workflows
  <span class="section-num">CALCULATION SUITE</span>
</h1>

<p>
  AstroDashaCare houses the most comprehensive calculation suite in digital Vedic astrology, powered by optimized client-side Dart mathematical libraries and backend Swiss Ephemeris algorithms.
</p>

<table>
  <thead>
    <tr>
      <th style="width: 25%;">Astrological Engine</th>
      <th style="width: 35%;">Theoretical Basis & Formulas</th>
      <th style="width: 40%;">Key Outputs & Screen Deliverables</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>1. Birth Chart & Vargas<br>(D1 to D60)</strong></td>
      <td>Lahiri Sidereal Ayanamsha, Sripathi / Placidus Bhava Cusps, Planetary Longitudes (Sun to Ketu).</td>
      <td>South & North Indian Rasi & Navamsha charts, Padasaram table, Combustion & Retrograde indicators.</td>
    </tr>
    <tr>
      <td><strong>2. Vimshottari Dasha Engine</strong></td>
      <td>120-year Nakshatra Dasha cycle. Balance of birth dasha calculated from Moon's arc in Janma Nakshatra.</td>
      <td>Mahadasha, Antardasha (Bhukti), Pratyantardasha, and Sookshma dasha start/end date timeline.</td>
    </tr>
    <tr>
      <td><strong>3. KP Astrology & Cusps</strong></td>
      <td>Krishnamurti Padhdhati (KP). 12 Placidus Cusps divided into Sign Lord, Star Lord, Sub Lord & Sub-Sub Lord.</td>
      <td>12 Cusp Sub-lords, Planet Sub-lords, 4-Fold Significators table, and KP Ruling Planets HUD.</td>
    </tr>
    <tr>
      <td><strong>4. KP Horary (1 to 249)</strong></td>
      <td>Prashna seed number (1-249) maps directly to exact Zodiac arc & Ascendant Sub-lord.</td>
      <td>Instant Horary Prashna Kundli, Query Significators, Sub-lord promise verification.</td>
    </tr>
    <tr>
      <td><strong>5. Bhrigu Nandi Nadi (BNN)</strong></td>
      <td>Sage Bhrigu & Nandikesha principles. Karaka planets (Guru=Jiva, Shani=Karma), 1-5-9 Trinal combinations, 2-12 links.</td>
      <td>Directional Trine groupings (East, South, West, North), Life event predictions, Yoga analysis.</td>
    </tr>
    <tr>
      <td><strong>6. Jamakol Arudam</strong></td>
      <td>Ancient Tamil Prashna system. Day divided into 8 Jamams (3.75 Nazhigai each), Udhayam, Aarudam, Kavippu & 8 Jamakkol planets.</td>
      <td>Complete Jamakkol Prashna Chakra, Kavippu danger point analysis, success/failure verdict.</td>
    </tr>
    <tr>
      <td><strong>7. Panchapakshi Shastra</strong></td>
      <td>Tamil Siddha 5-Bird Science (Vulture, Owl, Crow, Rooster, Peacock) by Sage Agathiyar. 5 states: Rule, Eat, Walk, Sleep, Die.</td>
      <td>Day & Night Yamam activity charts, auspicious micro-periods (Arasu/Oon) for negotiations, deals, travel.</td>
    </tr>
    <tr>
      <td><strong>8. Marriage Porutham</strong></td>
      <td>10 & 12 Poruthams (Dina, Gana, Mahendra, Stree Dheerkha, Yoni, Rasi, Rasiyadhipathi, Vashya, Rajju, Vedha).</td>
      <td>Total score out of 10/12, Sevvai (Manglik) Dosham check with exemptions, Rahu-Ketu Dosham, Papasamya score.</td>
    </tr>
    <tr>
      <td><strong>9. Ashtakavarga Matrix</strong></td>
      <td>8-fold benefic point contribution by 7 planets + Lagna. Sarvashtakavarga (SAV) & Bhinnashtakavarga (BAV).</td>
      <td>SAV 337 points distribution chart, Trikona Shodhana, Ekadhipatya Shodhana, Pinda Shodhana.</td>
    </tr>
    <tr>
      <td><strong>10. Live Hora & Dina Suddhi</strong></td>
      <td>Planetary horas based on local Sunrise/Sunset. 24 unequal horas per solar day with cyclic planetary rulers.</td>
      <td>Real-time active Hora countdown, favorable/unfavorable activity guide, Dina Suddhi 21-Dosha audit.</td>
    </tr>
    <tr>
      <td><strong>11. Pindayu Longevity</strong></td>
      <td>Classical Ayurdaya calculations. Identifies Maraka (2/7), Badhaka houses, Harana (reductions) for combust/enemy planets.</td>
      <td>Alpayu (0-32), Madhyayu (33-66), Deerghayu (67-100+) lifespan classification & longevity score.</td>
    </tr>
    <tr>
      <td><strong>12. Numerology & Lo Shu</strong></td>
      <td>Chaldean & Pythagorean systems. Root Number (Moolank), Destiny (Bhagyank), Name Number, 3x3 Lo Shu Grid.</td>
      <td>Lo Shu Element plane analysis (Mind, Soul, Practical), Lucky numbers, colors, gems, compatible dates.</td>
    </tr>
    <tr>
      <td><strong>13. Tamil Calendars</strong></td>
      <td>Tamil Solar Year (60-year cycle), Tamil Months (Chithirai to Panguni), Paksha, Nalla Neram, Rahu/Gulika Kalam.</td>
      <td>Daily Panchang card, Monthly Tamil Calendar view, Gowri Panchangam, Subha Muhurtham dates.</td>
    </tr>
    <tr>
      <td><strong>14. Tara Balam & Chandrashtama</strong></td>
      <td>9 Tara classifications (Janma, Sampat, Vipat, Kshema, Pratyak, Sadhana, Naidhana, Mitra, Param Mitra) across 27 stars.</td>
      <td>Daily Nakshatra strength index, Chandrashtama warning indicator (Moon in 8th from Janma Rasi).</td>
    </tr>
  </tbody>
</table>

<!-- ========================================================================= -->
<!-- SECTION 5: LIVE CONSULTATION, CALLING & BILLING ENGINE -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 5 • Consultation & Billing Engine</span>
</div>

<h1>
  5. Live Consultation, Calling & Billing Engine
  <span class="section-num">COMMUNICATION</span>
</h1>

<p>
  AstroDashaCare provides a seamless, secure tele-consultation pipeline linking Clients with certified Astrologers with dynamic per-minute billing and automatic wallet deduction.
</p>

<div class="section-card">
  <h2>🔄 Consultation Session Lifecycle Flow</h2>
  <div class="step-flow">
    <div class="step-node">
      <div class="step-badge">1</div>
      <div class="step-content">
        <h4>Astrologer Selection & Rate Inspection</h4>
        <p>User navigates to the Consult Tab, filters by specialization/language/rating, and inspects per-minute tariff (e.g., ₹30/min).</p>
      </div>
    </div>
    <div class="arrow-down">▼</div>

    <div class="step-node">
      <div class="step-badge">2</div>
      <div class="step-content">
        <h4>Pre-Call Wallet Sufficiency Validation (`PaymentService` & `WalletScreen`)</h4>
        <p>System verifies user has minimum required balance (at least 5 minutes worth of consultation). If insufficient, a fast top-up dialog is triggered via UPI / Razorpay.</p>
      </div>
    </div>
    <div class="arrow-down">▼</div>

    <div class="step-node">
      <div class="step-badge">3</div>
      <div class="step-content">
        <h4>Queue Entry & Signaling Handshake (`CallingService`)</h4>
        <p>Call request sent to backend FastAPI signaling hub. The Astrologer's device receives an interactive incoming call popup with client birth coordinates.</p>
      </div>
    </div>
    <div class="arrow-down">▼</div>

    <div class="step-node">
      <div class="step-badge">4</div>
      <div class="step-content">
        <h4>Active Consultation HUD (`ConsultationScreen`)</h4>
        <p>Upon connection, a real-time call timer initiates. Astrologer views a split-screen HUD showing client's live Rasi chart, current Mahadasha, notes panel, and mute/camera controls.</p>
      </div>
    </div>
    <div class="arrow-down">▼</div>

    <div class="step-node">
      <div class="step-badge">5</div>
      <div class="step-content">
        <h4>Dynamic Billing & Wallet Settlement</h4>
        <p>Wallet balance is deducted per minute. If balance runs out, audio prompt alerts the user with a 60-second grace window to recharge before auto-termination.</p>
      </div>
    </div>
    <div class="arrow-down">▼</div>

    <div class="step-node">
      <div class="step-badge">6</div>
      <div class="step-content">
        <h4>Post-Call Review & Rating Dialogue (`RatingDialog`)</h4>
        <p>Client submits 1-5 star rating and written testimonial. Astrologer's public rating and consultation count update automatically.</p>
      </div>
    </div>
  </div>
</div>

<div class="grid-2 no-break">
  <div class="section-card">
    <h2>💳 Wallet & Payment Architecture</h2>
    <ul class="module-card-list">
      <li><strong>Supported Payment Methods:</strong> Razorpay Gateway, UPI (GPay, PhonePe, Paytm), NetBanking, Credit/Debit Cards.</li>
      <li><strong>Wallet Top-Up Packs:</strong> ₹100, ₹250, ₹500, ₹1,000, ₹5,000 with promotional bonus cash.</li>
      <li><strong>60-Second Grace Rule:</strong> Calls disconnected &lt; 60 seconds due to network drops receive a 100% refund.</li>
      <li><strong>Ledger Transparency:</strong> Downloadable invoice statement with exact timestamps and per-second duration.</li>
    </ul>
  </div>

  <div class="section-card">
    <h2>🛍️ Astro Shop E-Commerce Engine</h2>
    <ul class="module-card-list">
      <li><strong>Certified Gemstones:</strong> Natural Ruby, Yellow Sapphire, Blue Sapphire, Emerald, Diamond, Red Coral, Hessonite.</li>
      <li><strong>Energized Rudraksha:</strong> 1 to 14 Mukhi laboratory-certified beads.</li>
      <li><strong>Sacred Yantras:</strong> Copper, Silver & Gold-plated Sri Yantra, Kuber Yantra, Navagraha Yantra.</li>
      <li><strong>Checkout Flow:</strong> In-app Cart &rarr; Address Entry &rarr; Wallet or Gateway Payment &rarr; Tracking ID.</li>
    </ul>
  </div>
</div>

<!-- ========================================================================= -->
<!-- SECTION 6: PDF HOROSCOPE EXPORT & CUSTOM BRANDING -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 6 • PDF Engine & REST APIs</span>
</div>

<h1>
  6. PDF Generation Engine & REST API Directory
  <span class="section-num">INTEGRATION</span>
</h1>

<div class="section-card">
  <h2>📄 Professional PDF Horoscope Engine (`PdfGeneratorService`)</h2>
  <p>
    AstroDashaCare contains an on-device PDF generation subsystem producing publication-grade, multi-page Tamil and English Sidereal Horoscope reports:
  </p>
  <div class="grid-3">
    <div class="module-card">
      <div class="module-card-title"><span>🏛️ Custom Branding</span></div>
      <p style="font-size: 8pt; color: #94A3B8;">Configurable Astrologer Center Name, Subtitle, Contact numbers, Address, and Custom Invocation Slokam in <code>CustomerDetailsSettingsScreen</code>.</p>
    </div>
    <div class="module-card">
      <div class="module-card-title"><span>📊 Vector Charts</span></div>
      <p style="font-size: 8pt; color: #94A3B8;">Crisp vector rendering of South Indian Rasi & Navamsha grids, planetary degrees, retrograde markers, and Pada distributions.</p>
    </div>
    <div class="module-card">
      <div class="module-card-title"><span>🔤 Unicode Tamil Fonts</span></div>
      <p style="font-size: 8pt; color: #94A3B8;">Integrated <code>PdfFontManager</code> supporting Noto Sans Tamil & Anek Tamil for rendering complex Tamil ligatures.</p>
    </div>
  </div>
</div>

<div class="section-card no-break">
  <h2>🌐 FastAPI RESTful API Endpoints Directory</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 15%;">Method</th>
        <th style="width: 35%;">Endpoint URI</th>
        <th style="width: 25%;">Access Level</th>
        <th style="width: 25%;">Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/auth/register</code></td>
        <td>Public</td>
        <td>Register new user or astrologer</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/auth/login</code></td>
        <td>Public</td>
        <td>Authenticate via phone/password</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/auth/google</code></td>
        <td>Public</td>
        <td>Google OAuth 2.0 verification</td>
      </tr>
      <tr>
        <td><span class="badge badge-cyan">GET</span></td>
        <td><code>/api/astrologers</code></td>
        <td>Public</td>
        <td>Fetch verified astrologer list</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/astrologers</code></td>
        <td>Admin</td>
        <td>Create new astrologer entry</td>
      </tr>
      <tr>
        <td><span class="badge badge-red">DELETE</span></td>
        <td><code>/api/astrologers/{id}</code></td>
        <td>Admin</td>
        <td>Remove astrologer from system</td>
      </tr>
      <tr>
        <td><span class="badge badge-cyan">GET</span></td>
        <td><code>/api/panchang/today</code></td>
        <td>Public</td>
        <td>Get daily panchang calculations</td>
      </tr>
      <tr>
        <td><span class="badge badge-purple">PUT</span></td>
        <td><code>/api/panchang/entry</code></td>
        <td>Admin</td>
        <td>Admin Panchang CMS update</td>
      </tr>
      <tr>
        <td><span class="badge badge-cyan">GET</span></td>
        <td><code>/api/terms</code></td>
        <td>Public</td>
        <td>Fetch active Terms & Conditions</td>
      </tr>
      <tr>
        <td><span class="badge badge-purple">PUT</span></td>
        <td><code>/api/terms</code></td>
        <td>Admin</td>
        <td>Update dynamic platform policies</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/wallet/topup</code></td>
        <td>User / Admin</td>
        <td>Credit funds to user wallet</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/wallet/deduct</code></td>
        <td>System</td>
        <td>Per-minute consultation billing</td>
      </tr>
      <tr>
        <td><span class="badge badge-cyan">GET</span></td>
        <td><code>/api/magazine/feed</code></td>
        <td>Public</td>
        <td>Fetch Astrogen Magazine articles</td>
      </tr>
      <tr>
        <td><span class="badge badge-green">POST</span></td>
        <td><code>/api/magazine/article</code></td>
        <td>Admin</td>
        <td>Publish new magazine article</td>
      </tr>
    </tbody>
  </table>
</div>

<div class="callout callout-purple no-break">
  <strong>🌟 Offline Resilience:</strong> The backend API includes an automatic in-memory <code>mongomock</code> engine with file-backed JSON serialization (<code>astrocall_mongodb_data.json</code>), ensuring that the system functions seamlessly even when external MongoDB servers are offline.
</div>

<!-- ========================================================================= -->
<!-- SECTION 7: SUMMARY & CONCLUSION -->
<!-- ========================================================================= -->
<div class="page-break"></div>

<div class="doc-header">
  <span class="app-brand">AstroDashaCare Architecture Specification</span>
  <span>Section 7 • Summary & Roadmap</span>
</div>

<h1>
  7. Summary, Technical Highlights & Roadmap
  <span class="section-num">ROADMAP</span>
</h1>

<div class="section-card">
  <h2>✨ Key Architectural Highlights</h2>
  <div class="grid-2">
    <div>
      <h3 style="color: #FFD700;">🚀 Performance & Scalability</h3>
      <p style="font-size: 8.5pt;">All 20+ astrological calculation routines run locally on client devices with near-zero latency, avoiding expensive round-trips for core mathematical charts.</p>
    </div>
    <div>
      <h3 style="color: #00F0FF;">🎨 Cosmic Glassmorphic Aesthetics</h3>
      <p style="font-size: 8.5pt;">Custom dark theme with tailored HSL tokens (Deep Space <code>#050914</code>, Radiant Gold <code>#FFD700</code>, Cyber Cyan <code>#00F0FF</code>, Cosmic Violet <code>#8A2BE2</code>).</p>
    </div>
    <div>
      <h3 style="color: #4ADE80;">🔒 Fault-Tolerant Persistence</h3>
      <p style="font-size: 8.5pt;">Dual-strategy persistence ensuring zero data loss during network outages with persistent JSON disk state serialization.</p>
    </div>
    <div>
      <h3 style="color: #C084FC;">🤖 AI-Augmented Astrology</h3>
      <p style="font-size: 8.5pt;">Deep integration with AI Assistant models contextualized with native Kundli placements for instant remedial insights.</p>
    </div>
  </div>
</div>

<div class="section-card no-break">
  <h2>🗺️ Complete Route Navigation Index</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 25%;">Named Route</th>
        <th style="width: 30%;">Dart Screen Class</th>
        <th style="width: 15%;">Guarded Role</th>
        <th style="width: 30%;">Module Purpose</th>
      </tr>
    </thead>
    <tbody>
      <tr><td><code>/</code></td><td><code>SplashScreen</code></td><td>Public</td><td>Cinematic Splash & Bootstrapping</td></tr>
      <tr><td><code>/login</code></td><td><code>LoginScreen</code></td><td>Public</td><td>Multi-Role Authentication & OAuth</td></tr>
      <tr><td><code>/terms</code></td><td><code>TermsConditionsScreen</code></td><td>Public</td><td>Mandatory Terms Acceptance</td></tr>
      <tr><td><code>/profile</code></td><td><code>UserHoroscopeProfileScreen</code></td><td>Public</td><td>Birth Chart Profile Builder</td></tr>
      <tr><td><code>/user_dashboard</code></td><td><code>DashboardScreen</code></td><td>User / Any</td><td>Client Home Hub & Services Grid</td></tr>
      <tr><td><code>/astrologer_dashboard</code></td><td><code>AstrologerDashboardScreen</code></td><td>Astrologer</td><td>Live Call Queue & Workspace</td></tr>
      <tr><td><code>/admin_dashboard</code></td><td><code>AdminDashboardScreen</code></td><td>Admin</td><td>Master CMS & Roster Management</td></tr>
      <tr><td><code>/admin_panchang</code></td><td><code>AdminPanchangCmsScreen</code></td><td>Admin</td><td>Daily Panchang CMS Editor</td></tr>
      <tr><td><code>/admin_planet_positions</code></td><td><code>AdminPlanetPositionsCmsScreen</code></td><td>Admin</td><td>Ephemeris & Coordinates CMS</td></tr>
      <tr><td><code>/admin_terms</code></td><td><code>AdminTermsCmsScreen</code></td><td>Admin</td><td>Legal Policy & Disclaimer CMS</td></tr>
      <tr><td><code>/birth_chart</code></td><td><code>BirthChartScreen</code></td><td>Public</td><td>D1 to D60 Kundli & Padasaram</td></tr>
      <tr><td><code>/kp_astrology</code></td><td><code>KpAstrologyScreen</code></td><td>Public</td><td>KP 12 Cusps & Sub-Lord System</td></tr>
      <tr><td><code>/kp_horary</code></td><td><code>KpHoraryScreen</code></td><td>Public</td><td>1-249 Horary Prashna Engine</td></tr>
      <tr><td><code>/bhrigu_nandi_nadi</code></td><td><code>BhriguNandiNadiScreen</code></td><td>Public</td><td>BNN Trine & Directional Combinations</td></tr>
      <tr><td><code>/jamakol_arudam</code></td><td><code>JamakolArudamScreen</code></td><td>Public</td><td>Tamil Jamakkol Prashna Chakra</td></tr>
      <tr><td><code>/panchapakshi</code></td><td><code>PanchapakshiScreen</code></td><td>Public</td><td>Siddha 5-Bird Auspicious Timings</td></tr>
      <tr><td><code>/marriage_porutham</code></td><td><code>MarriagePoruthamScreen</code></td><td>Public</td><td>10/12 Poruthams & Dosha Matching</td></tr>
      <tr><td><code>/ashtakavarga</code></td><td><code>AshtakavargaScreen</code></td><td>Public</td><td>SAV & BAV 337-Point Matrices</td></tr>
      <tr><td><code>/hora</code></td><td><code>LiveHoraScreen</code></td><td>Public</td><td>Live Planetary Hora Schedule</td></tr>
      <tr><td><code>/nazhigai</code></td><td><code>NazhigaiScreen</code></td><td>Public</td><td>Udayadhi Nazhigai Timekeeping</td></tr>
      <tr><td><code>/longevity</code></td><td><code>LongevityScreen</code></td><td>Public</td><td>Classical Pindayu Longevity Estimator</td></tr>
      <tr><td><code>/daily_calendar</code></td><td><code>DailyCalendarScreen</code></td><td>Public</td><td>Daily Panchang, Tithi & Gowri Time</td></tr>
      <tr><td><code>/tamil_month_calendar</code></td><td><code>TamilMonthCalendarScreen</code></td><td>Public</td><td>Tamil Monthly Calendar & Festivals</td></tr>
      <tr><td><code>/numerology</code></td><td><code>NumerologyScreen</code></td><td>Public</td><td>Chaldean & Pythagorean Numerology</td></tr>
      <tr><td><code>/tara_balam</code></td><td><code>TaraBalamScreen</code></td><td>Public</td><td>9-Tara Strength & Chandrashtama</td></tr>
      <tr><td><code>/ai_assistant</code></td><td><code>AiHoroscopeScreen</code></td><td>Public</td><td>AI Astrological Chatbot Guru</td></tr>
      <tr><td><code>/shop</code></td><td><code>ShopScreen</code></td><td>Public</td><td>Gemstones, Rudrakshas & Yantras</td></tr>
      <tr><td><code>/wallet</code></td><td><code>WalletScreen</code></td><td>User / Admin</td><td>Wallet Recharge, History & Ledger</td></tr>
      <tr><td><code>/magazine</code></td><td><code>MagazineFeedScreen</code></td><td>Public</td><td>Astrogen Digital Magazine & Articles</td></tr>
      <tr><td><code>/pdf_settings</code></td><td><code>CustomerDetailsSettingsScreen</code></td><td>Public</td><td>Custom PDF Header/Footer Settings</td></tr>
      <tr><td><code>/mundane_astrology</code></td><td><code>MundaneAstrologyScreen</code></td><td>Admin</td><td>National Kundli & Geopolitics</td></tr>
    </tbody>
  </table>
</div>

<div class="cover-footer" style="margin-top: 20px;">
  © 2026 AstroDashaCare Digital Consulting Center. All Rights Reserved. • Designed for High-Performance Astrological Computing
</div>

</body>
</html>
"""

# Write HTML file
html_file_path = os.path.abspath("AstroDashaCare_Workflow_Document.html")
with open(html_file_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"[Created] HTML Document at: {html_file_path}")

# PDF output paths
pdf_target_1 = os.path.abspath("AstroDashaCare_App_Workflow.pdf")
pdf_target_root = os.path.abspath("../AstroDashaCare_App_Workflow.pdf")
artifact_dir = r"C:\Users\ADMIN\.gemini\antigravity-ide\brain\6377adb4-6b63-412b-8300-bab5300e2d34"
os.makedirs(artifact_dir, exist_ok=True)
pdf_target_artifact = os.path.join(artifact_dir, "AstroDashaCare_App_Workflow.pdf")

edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not os.path.exists(edge_path):
    edge_path = r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"

print(f"[Rendering] Converting to PDF via Microsoft Edge headless: {edge_path}")

cmd = [
    edge_path,
    "--headless=new",
    "--disable-gpu",
    "--no-pdf-header-footer",
    f"--print-to-pdf={pdf_target_1}",
    html_file_path
]

res = subprocess.run(cmd, capture_output=True, text=True)
if os.path.exists(pdf_target_1):
    size_kb = os.path.getsize(pdf_target_1) / 1024
    print(f"[Success] PDF generated successfully! Size: {size_kb:.2f} KB at {pdf_target_1}")
    
    # Copy to root and artifact directory
    import shutil
    shutil.copyfile(pdf_target_1, pdf_target_root)
    print(f"[Copied] PDF copied to workspace root: {pdf_target_root}")
    shutil.copyfile(pdf_target_1, pdf_target_artifact)
    print(f"[Copied] PDF copied to artifact directory: {pdf_target_artifact}")
else:
    print(f"[Error] Failed to create PDF. Stdout: {res.stdout}, Stderr: {res.stderr}")
