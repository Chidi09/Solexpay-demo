/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {
      colors: {
        // Primary palette
        "primary": "#005bbf",
        "on-primary": "#ffffff",
        "primary-container": "#1a73e8",
        "on-primary-container": "#ffffff",
        "primary-fixed": "#d8e2ff",
        "on-primary-fixed": "#001a41",
        "primary-fixed-dim": "#adc7ff",
        "on-primary-fixed-variant": "#004493",
        "inverse-primary": "#adc7ff",

        // Secondary palette
        "secondary": "#2b5bb5",
        "on-secondary": "#ffffff",
        "secondary-container": "#759efd",
        "on-secondary-container": "#00337c",
        "secondary-fixed": "#d9e2ff",
        "on-secondary-fixed": "#001945",
        "secondary-fixed-dim": "#b0c6ff",
        "on-secondary-fixed-variant": "#00429c",

        // Tertiary palette (Money-In / Success)
        "tertiary": "#006d2c",
        "on-tertiary": "#ffffff",
        "tertiary-container": "#008939",
        "on-tertiary-container": "#ffffff",
        "tertiary-fixed": "#89fa9b",
        "on-tertiary-fixed": "#002108",
        "tertiary-fixed-dim": "#6ddd81",
        "on-tertiary-fixed-variant": "#005320",

        // Error palette
        "error": "#ba1a1a",
        "on-error": "#ffffff",
        "error-container": "#ffdad6",
        "on-error-container": "#93000a",

        // Surface palette
        "surface": "#f8f9fa",
        "on-surface": "#191c1d",
        "surface-variant": "#e1e3e4",
        "on-surface-variant": "#414754",
        "inverse-surface": "#2e3132",
        "inverse-on-surface": "#f0f1f2",
        "background": "#f8f9fa",
        "on-background": "#191c1d",

        // Outline
        "outline": "#727785",
        "outline-variant": "#c1c6d6",

        // Surface containers (for the "No-Line" rule)
        "surface-container-lowest": "#ffffff",
        "surface-container-low": "#f3f4f5",
        "surface-container": "#edeeef",
        "surface-container-high": "#e7e8e9",
        "surface-container-highest": "#e1e3e4",
        "surface-bright": "#f8f9fa",
        "surface-dim": "#d9dadb",
        "surface-tint": "#005bc0",
      },
      fontFamily: {
        headline: ['"Plus Jakarta Sans"', "Inter", "sans-serif"],
        display: ['"Plus Jakarta Sans"', "Inter", "sans-serif"],
        body: ["Inter", "sans-serif"],
        label: ["Inter", "sans-serif"],
      },
      borderRadius: {
        DEFAULT: "0.25rem",
        md: "12px",
        lg: "16px",
        xl: "24px",
        full: "9999px",
      },
      keyframes: {
        "count-up": {
          from: { opacity: "0", transform: "translateY(8px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        "bar-grow": {
          from: { transform: "scaleY(0)", transformOrigin: "bottom" },
          to: { transform: "scaleY(1)", transformOrigin: "bottom" },
        },
        "fade-slide-up": {
          from: { opacity: "0", transform: "translateY(16px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        "skeleton-pulse": {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.4" },
        },
        "notification-dot": {
          "0%, 100%": { transform: "scale(1)" },
          "50%": { transform: "scale(1.4)" },
        },
        "drawer-slide-in": {
          from: { transform: "translateX(100%)" },
          to: { transform: "translateX(0)" },
        },
        "modal-scale-in": {
          from: { opacity: "0", transform: "scale(0.95)" },
          to: { opacity: "1", transform: "scale(1)" },
        },
        "toast-in": {
          from: { opacity: "0", transform: "translateY(20px) scale(0.95)" },
          to: { opacity: "1", transform: "translateY(0) scale(1)" },
        },
        "ripple": {
          from: { transform: "scale(0)", opacity: "0.3" },
          to: { transform: "scale(4)", opacity: "0" },
        },
        "card-lift": {
          from: { transform: "translateY(0)" },
          to: { transform: "translateY(-3px)" },
        },
        "stagger-in": {
          from: { opacity: "0", transform: "translateX(-8px)" },
          to: { opacity: "1", transform: "translateX(0)" },
        },
      },
      animation: {
        "count-up": "count-up 0.4s ease-out forwards",
        "bar-grow": "bar-grow 0.6s cubic-bezier(0.34,1.56,0.64,1) forwards",
        "fade-slide-up": "fade-slide-up 0.35s ease-out forwards",
        "skeleton-pulse": "skeleton-pulse 1.5s ease-in-out infinite",
        "notification-dot": "notification-dot 2s ease-in-out infinite",
        "drawer-slide-in": "drawer-slide-in 0.3s cubic-bezier(0.32,0.72,0,1) forwards",
        "modal-scale-in": "modal-scale-in 0.2s ease-out forwards",
        "toast-in": "toast-in 0.3s cubic-bezier(0.34,1.56,0.64,1) forwards",
        "ripple": "ripple 0.6s linear forwards",
        "stagger-in": "stagger-in 0.3s ease-out forwards",
      },
    },
  },
  plugins: [],
}
