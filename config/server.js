require("dotenv").config();

module.exports = ({ env }) => ({
  host: "127.0.0.1",
  port: env.int("PORT", 1337),

  url: env("PUBLIC_URL", "http://localhost:1337"),

  proxy: false, // NO reverse proxy in local dev

  app: {
    keys: env.array("APP_KEYS"),
  },

  webhooks: {
    populateRelations: env.bool("WEBHOOKS_POPULATE_RELATIONS", false),
  },
});
