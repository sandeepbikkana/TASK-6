// module.exports = ({ env }) => ({
//   connection: {
//     client: 'postgres',
//     connection: {
//       host: env('DATABASE_HOST', 'postgres'),
//       port: env.int('DATABASE_PORT', 5432),
//       database: env('DATABASE_NAME', 'postgres'),
//       user: env('DATABASE_USERNAME', 'postgres'),
//       password: env('DATABASE_PASSWORD', 'postgres'),

//       ssl: false,   // IMPORTANT: DISABLE SSL FOR LOCAL DEVELOPMENT
//     },
//   },
// });


module.exports = ({ env }) => ({
  connection: {
    client: env("DATABASE_CLIENT", "postgres"),
    connection: {
      host: env("DATABASE_HOST", "localhost"),
      port: env.int("DATABASE_PORT", 5432),
      database: env("DATABASE_NAME", "postgres"),
      user: env("DATABASE_USERNAME", "postgres"),
      password: env("DATABASE_PASSWORD", "postgres"),
      ssl: env.bool("DATABASE_SSL", false),
    },
  },
});
