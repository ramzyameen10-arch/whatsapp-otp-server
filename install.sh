Cat << 'EOF' > final_setup.sh
#!/bin/bash

echo "------------------------------------------------"
echo "🚀 بدء الإعداد الشامل لسيرفر واتساب (Bio-Heartbeat) - رمزي أمين"
echo "------------------------------------------------"

# 1. طلب المعلومات الأساسية
read -p "DOMAIN: " DOMAIN
read -p "EMAIL : " EMAIL

# 2. تحديث النظام وتثبيت المكتبات الأساسية
echo "⏳ جاري تحديث النظام وتثبيت المتصفح..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y nodejs npm certbot chromium-browser fonts-liberation libasound2t64 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc-s1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release xdg-utils curl

# 3. إعداد الذاكرة الوهمية (Swap) 2GB - حيوية جداً لرام 512
if [ ! -f /swapfile ]; then
    echo "🛠️ جاري إنشاء الذاكرة الوهمية (2GB)..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "✅ تم تفعيل الـ Swap بنجاح."
else
    echo "ℹ️ الـ Swap موجود بالفعل."
fi

# 4. إصدار شهادة الأمان SSL
echo "🔐 جاري إصدار شهادة SSL للدومين $DOMAIN..."
sudo certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# 5. تثبيت مكتبات Node.js
echo "📦 جاري تثبيت مكتبات المشروع..."
npm install express whatsapp-web.js qrcode-terminal qrcode axios

# 6. إنشاء ملف index.js المطور (مع حل مشكلة التايمر والذاكرة)
echo "📝 جاري كتابة ملف index.js المطور..."
cat << 'INDEX_EOF' > index.js
const https = require('https');
const fs = require('fs');
const express = require('express');
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcodeTerminal = require('qrcode-terminal');
const QRCode = require('qrcode');

const app = express();
app.use(express.json());

// المتغير في مكانه الصحيح (Global Scope) لضمان عدم تكرار النبضات
let heartbeatTimer = null;

const domain = "DOMAIN_PLACEHOLDER";
const options = {
    cert: fs.readFileSync(`/etc/letsencrypt/live/${domain}/fullchain.pem`),
    key: fs.readFileSync(`/etc/letsencrypt/live/${domain}/privkey.pem`)
};

let latestQR = "";

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        executablePath: '/usr/bin/chromium-browser',
        args: [
            '--no-sandbox', 
            '--disable-setuid-sandbox', 
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--single-process',
            '--disable-gpu'
        ]
    }
});

client.on('qr', (qr) => {
    latestQR = qr;
    console.log('\n📸 امسح الرمز من الرابط أدناه:');
    qrcodeTerminal.generate(qr, { small: true });
});

client.on('ready', () => {
    latestQR = "";
    console.log('✅ واتساب جاهز للإرسال!');
    
    // تنظيف أي تايمر قديم قبل بدء الجديد (لمنع تكرار Heartbeat)
    if (heartbeatTimer) clearInterval(heartbeatTimer);

    heartbeatTimer = setInterval(async () => {
        try {
            if (client && client.pupPage && !client.pupPage.isClosed()) {
                const now = new Date().toLocaleString('ar-SA', { timeZone: 'Asia/Riyadh' });
                await client.setStatus(`Active: ${now} | Server Online 🚀`);
                console.log(`💓 Heartbeat: Bio updated at ${now}`);
            }
        } catch (e) {
            console.error('⚠️ Heartbeat failed (Memory pressure)');
        }
    }, 15 * 60 * 1000); 
});

client.initialize();

app.get('/scan', async (req, res) => {
    if (!latestQR) return res.send('<h1 style="text-align:center;font-family:Arial;margin-top:50px;">✅ WhatsApp is Connected!</h1>');
    try {
        const qrImage = await QRCode.toDataURL(latestQR);
        res.send(`
            <div style="text-align:center;margin-top:50px;font-family:Arial;">
                <h2>Scan QR Code to Connect WhatsApp</h2>
                <img src="${qrImage}" width="300" style="border:10px solid white;box-shadow:0 0 10px rgba(0,0,0,0.1);"/>
                <p>Refresh page if QR expires.</p>
            </div>
        `);
    } catch (err) { res.status(500).send('Error'); }
});

app.post('/webhook/new-order', async (req, res) => {
    const data = req.body.record ? req.body.record : req.body;
    const phone = (data.phone_number || data.phone || "").toString();
    const otp = (data.otp_code || data.code || "").toString();

    if (!phone || !otp) return res.status(400).send('Missing data');

    try {
        if (client && client.info && client.pupPage && !client.pupPage.isClosed()) {
            const chatId = `${phone.replace(/[^0-9]/g, '')}@c.us`;
            await client.sendMessage(chatId, `كود التحقق الخاص بك هو: ${otp}`);
            console.log(`✅ Sent OTP to: ${phone}`);
            res.status(200).send('Success');
        } else {
            res.status(503).send('Service Unavailable');
        }
    } catch (e) {
        console.error('❌ Sending Error:', e.message);
        res.status(500).send('Error');
    }
});

https.createServer(options, app).listen(443, '0.0.0.0', () => {
    console.log('🚀 السيرفر يعمل الآن بنجاح عبر HTTPS');
});
INDEX_EOF

# ربط الدومين بالملف
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" index.js

# 7. تشغيل وتأمين PM2
echo "⚙️ ضبط التشغيل الدائم عبر PM2..."
sudo npm install pm2 -g
sudo pm2 stop all 2>/dev/null
sudo pm2 delete "whatsapp-otp" 2>/dev/null
# إعداد إعادة التشغيل التلقائي إذا تجاوز استهلاك الرام 400MB
sudo pm2 start index.js --name "whatsapp-otp" --max-memory-restart 400M
sudo pm2 save
sudo pm2 startup | tail -n 1 | bash

echo "------------------------------------------------"
echo "✅ اكتملت المهمة بنجاح!"
echo "📍 Webhook: https://$DOMAIN/webhook/new-order"
echo "📸 Scan QR: https://$DOMAIN/scan"
echo "------------------------------------------------"
EOF

chmod +x final_setup.sh
./final_setup.sh
