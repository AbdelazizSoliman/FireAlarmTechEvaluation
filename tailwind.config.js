module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
  ],
  plugins: [require('@tailwindcss/forms')],
  theme: {
    extend: {
      colors: {
        sidebarBg: '#221E1E',
        sidebarActiveBg: '#A91E1C',
        white: '#FFFFFF',
        logoTextBlack: '#000000',
        sidebarBorder: '#3A3A3A',
        buttonRed: '#B91C1C',
        formLabel: '#3A3A3A',
        formInputBorder: '#D7D2D5',
        tableHeaderBg: '#F9FAFB', // light gray for table header background
        tableRowHoverBg: '#F3F4F6', // light gray for hover effect on table rows
        buttonHoverBg: '#A91E1C', // button hover background color
        buttonText: '#FFFFFF', // button text color
        grayBg: '#D9D9D966',
        darkGray: '#78716C',
      },
    },
  },
};

