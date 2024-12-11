const defaultTheme = require('tailwindcss/defaultTheme');
const colors = require('tailwindcss/colors');


module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        neutral: "#1c1917",
        "neutral-content": "#f5f5f4",
        primary: "#4c1d95",
        "primary-content": "#f5f3ff",
        danger: "#dc2626",
        "danger-content": "#fef2f2",
        success: "#059669",
        "success-content": "#ecfdf5",
        warning: "#f59e0b",
        "warning-content": "#fffbeb",
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
