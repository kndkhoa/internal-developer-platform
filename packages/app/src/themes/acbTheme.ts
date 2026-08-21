import {
  createUnifiedTheme,
  genPageTheme,
  palettes,
  shapes,
} from '@backstage/theme';

export const acbTheme = createUnifiedTheme({
  palette: {
    ...palettes.light,
    primary: {
      main: '#0055A5',
      light: '#2A74C4',
      dark: '#003B7A',
      contrastText: '#ffffff',
    },
    secondary: {
      main: '#00A3E0',
      light: '#33B5E7',
      dark: '#0082C8',
      contrastText: '#ffffff',
    },
    background: {
      default: '#F4F7FA',
      paper: '#ffffff',
    },
    status: {
      ok: '#10B981',
      warning: '#F59E0B',
      error: '#EF4444',
      running: '#00A3E0',
      pending: '#6B7280',
      aborted: '#9CA3AF',
    },
    navigation: {
      background: '#003B7A',
      indicator: '#00A3E0',
      color: '#D1E3F6',
      selectedColor: '#ffffff',
      navItem: {
        hoverBackground: '#00488A',
      },
      submenu: {
        background: '#002D5E',
      },
    },
    border: '#E2E8F0',
    link: '#0055A5',
    linkHover: '#003B7A',
  },
  defaultPageTheme: 'home',
  pageTheme: {
    home: genPageTheme({
      colors: ['#0055A5', '#003B7A'],
      shape: shapes.wave,
    }),
    documentation: genPageTheme({
      colors: ['#003B7A', '#002D5E'],
      shape: shapes.wave2,
    }),
    tool: genPageTheme({
      colors: ['#00A3E0', '#0055A5'],
      shape: shapes.round,
    }),
    service: genPageTheme({
      colors: ['#0055A5', '#003B7A'],
      shape: shapes.wave,
    }),
    website: genPageTheme({
      colors: ['#0055A5', '#0082C8'],
      shape: shapes.wave,
    }),
    library: genPageTheme({
      colors: ['#003B7A', '#00A3E0'],
      shape: shapes.wave2,
    }),
    other: genPageTheme({
      colors: ['#0055A5', '#003B7A'],
      shape: shapes.wave,
    }),
    app: genPageTheme({
      colors: ['#0055A5', '#003B7A'],
      shape: shapes.wave,
    }),
  },
  fontFamily: '"Inter", "Roboto", "Helvetica Neue", "Arial", sans-serif',
});
