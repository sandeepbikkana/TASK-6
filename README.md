Task-1 : Strapi Local Setup & Content Type Creation
 Strapi Local Setup & Content Type Creation
## Objectives
- Clone the Strapi repository from GitHub  
- Run Strapi locally  
- Explore project folder structure  
- Access Admin Panel  
- Create Content Type
---
## Steps Performed
## 1. Clone Strapi Repository git clone 
```
git clone https://github.com/strapi/strapi.git
```
## 2. Install Dependencies
 ```
- npm install
- npx
```
## 3. Explore Folder Structure
- Check the project folders like src/, package.json, node_modules/.
## 4. Create a New Strapi Project
```
- npx create-strapi@latest  lovepreet-strapi-project --quickstart
  ```
 - This creates a new folder lovepreet-strapi-project

    

## 5. Run Strapi Locally
```
- cd lovepreet-strapi-project
- npm run develop
```
##6. Admin Panel
- Admin Panel URL: [http://localhost:1337/admin]
- First-time login: create admin account (email + password).
## 7. Create Content Type: 
- Fields:
- title → Short text    
- Number→ Long Integer    
- EMail → Mail
- Publish.

File structure:
my-project/
│
├── config/               → Strapi configurations
├── data/                 → SQLite database
├── public/               → Uploaded files
├── src/                  → Main application code
│   ├── admin/            → Admin panel UI logic
│   ├── api/              → Content types + routes + controllers
│   ├── components/       → Reusable components
│   ├── extensions/       → Plugin customizations
│   └── index.js
│
├── .env                  → Environment variables
├── package.json          → Dependencies + scripts and lock-package -> after all the dependencies installed by npm stated here 
└── .tmp/                 → Runtime generated files
