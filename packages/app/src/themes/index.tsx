import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { ThemeBlueprint } from '@backstage/plugin-app-react';
import { UnifiedThemeProvider } from '@backstage/theme';
import { acbTheme } from './acbTheme';

export const acbThemeExtension = ThemeBlueprint.make({
  name: 'acb',
  params: {
    theme: {
      id: 'acb-theme',
      title: 'ACB Corporate',
      variant: 'light',
      Provider: ({ children }) => (
        <UnifiedThemeProvider theme={acbTheme} children={children} />
      ),
    },
  },
});

export const acbThemeModule = createFrontendModule({
  pluginId: 'app',
  extensions: [acbThemeExtension],
});

export { acbTheme };
