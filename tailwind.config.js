module.exports = {
  purge: [
    './src/**/*.elm',
    './src/**/*.js',
    './dist/index.html',
  ],
  theme: {
    extend: {
      screens: {
        'print': { 'raw': 'print' },
      }
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/ui'),
  ],
}
