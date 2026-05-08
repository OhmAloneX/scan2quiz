/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        navy: {
          900: '#060d1f',
          800: '#0a1628',
          700: '#0d1f3c',
        },
      },
    },
  },
  plugins: [],
}