import elm from 'rollup-plugin-elm';
import postcss from 'rollup-plugin-postcss';
import hmr from 'rollup-plugin-hot';

// import resolve from '@rollup/plugin-node-resolve';
// import commonjs from '@rollup/plugin-commonjs';

const isProduction = process.env.NODE_ENV === 'production';

export default {
  input: 'src/index.js',
  output: isProduction ? {} : {
    dir: 'dist',
  },
  output: {
    file: 'dist/bundle.js',
    format: 'iife'
  },
  plugins: [
    elm({
      exclude: 'elm-stuff/**',
      compiler: {
        debug: !isProduction,
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
    !isProduction && hmr({
      public: 'dist',
      baseUrl: '/',
      port: 12345,
      host: '0.0.0.0',
    })
  ]
};
