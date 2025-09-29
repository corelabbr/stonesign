<h1 align="center" style="border-bottom: none">
  <div>
    <a href="https://www.stonesign.com.br">
      <img  alt="StoneSign" src="https://github.com/corelabbr/stonesign/assets/5418788/c12cd051-81cd-4402-bc3a-92f2cfdc1b06" width="80" />
      <br>
    </a>
    StoneSign
  </div>
</h1>
<h3 align="center">
  Open source document filling and signing
</h3>
<p align="center">
  <a href="https://discord.gg/qygYCDGck9">
    <img src="https://img.shields.io/discord/1125112641170448454?logo=discord"/>
  </a>
  <a href="https://twitter.com/intent/follow?screen_name=stonesign">
    <img src="https://img.shields.io/twitter/follow/stonesign?style=social" alt="Follow @stonesign" />
  </a>
</p>
<p>
StoneSign is an open source platform that provides secure and efficient digital document signing and processing. Create PDF forms to have them filled and signed online on any device with an easy-to-use, mobile-optimized web tool.
</p>
<h2 align="center">
  <a href="https://demo.stonesign.com.br">✨ Live Demo</a>
  <span>|</span>
  <a href="https://stonesign.com.br/sign_up">☁️ Try in Cloud</a>
</h2>

[![Demo](https://github.com/corelabbr/stonesign/assets/5418788/d8703ea3-361a-423f-8bfe-eff1bd9dbe14)](https://demo.stonesign.com.br)

## Features
- [x] PDF form fields builder (WYSIWYG)
- [x] 11 field types available (Signature, Date, File, Checkbox etc.)
- [x] Multiple submitters per document
- [x] Automated emails via SMTP
- [x] Files storage on disk or AWS S3, Google Storage, Azure Cloud
- [x] Automatic PDF eSignature
- [x] PDF signature verification
- [x] Users management
- [x] Mobile-optimized
- [x] API and Webhooks for integrations
- [x] Easy to deploy in minutes

#### Docker

```sh
docker build -t stonesign .
docker-compose build
docker run --name stonesign -p 3000:3000 -v.:/data stonesign
```

By default StoneSign docker container uses an SQLite database to store data and configurations. Alternatively, it is possible use PostgreSQL or MySQL databases by specifying the `DATABASE_URL` env variable.

#### Docker Compose

Download docker-compose.yml into your private server:
```sh
curl https://raw.githubusercontent.com/stonesignco/stonesign/master/docker-compose.yml > docker-compose.yml
```

Run the app under a custom domain over https using docker compose (make sure your DNS points to the server to automatically issue ssl certs with Caddy):
```sh
HOST=your-domain-name.com docker-compose up
```

## For Businesses
### Integrate seamless document signing into your web or mobile apps with StoneSign!

At StoneSign we have expertise and technologies to make documents creation, filling, signing and processing seamlessly integrated with your product. We specialize in working with various industries, including **Banking, Healthcare, Transport, Real Estate, eCommerce, KYC, CRM, and other software products** that require bulk document signing. By leveraging StoneSign, we can assist in reducing the overall cost of developing and processing electronic documents while ensuring security and compliance with local electronic document laws.

[Book a Meeting](https://calendly.com/kriti-stonesign/30min)

## License

Distributed under the AGPLv3 License. See [LICENSE](https://github.com/corelabbr/stonesign/blob/master/LICENSE) for more information.
Unless otherwise noted, all files © 2023 StoneSign LLC.


bundle exec rails db:create db:migrate
bundle exec rails db:seed
npm install

bin/shakapacker-dev-server