import elm from 'rollup-plugin-elm';
import postcss from 'rollup-plugin-postcss';
import hmr from 'rollup-plugin-hot';

// import resolve from '@rollup/plugin-node-resolve';
// import commonjs from '@rollup/plugin-commonjs';

export default {
  input: 'src/index.js',
  output: {
    dir: 'dist',
    file: 'dist/bundle.js',
    format: 'iife'
  },
  plugins: [
    elm({
      exclude: 'elm-stuff/**',
      compiler: {
        debug: true
      }
    }),
    // resolve(),
    // commonjs(),
    postcss({
      plugins: [
        require('tailwindcss')('./tailwind.config.js'),
        require('autoprefixer'),        
      ]
    }),

    hmr({
      public: 'dist',
      baseUrl: '/',
      port: 12345,
      host: '0.0.0.0',
    })
  ]
};
