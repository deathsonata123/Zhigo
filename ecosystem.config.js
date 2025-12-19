# PM2 Ecosystem Configuration

module.exports = {
  apps: [
    // Express.js Backend API
    {
      name: 'zhigo-api',
      script: './backend-express/dist/server.js',
      instances: 2,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/api-error.log',
      out_file: './logs/api-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // Admin Dashboard (Next.js)
    {
      name: 'admin-dashboard',
      script: 'npm',
      args: 'start',
      cwd: './web/admin-dashboard',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      error_file: './logs/admin-error.log',
      out_file: './logs/admin-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // Restaurant Dashboard (Next.js)
    {
      name: 'restaurant-dashboard',
      script: 'npm',
      args: 'start',
      cwd: './web/restaurant-dashboard',
      env: {
        NODE_ENV: 'production',
        PORT: 3002
      },
      error_file: './logs/restaurant-error.log',
      out_file: './logs/restaurant-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
