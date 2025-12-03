module.exports = ({ env }) => ({
  upload: {
    config: {
      provider: 'local',
      providerOptions: {
        sizeLimit: 10000000, // 10MB
      },
    },
  },

  'users-permissions': {
    config: {
      jwtSecret: env('JWT_SECRET', 'local-dev-secret'),
    },
  },
});
