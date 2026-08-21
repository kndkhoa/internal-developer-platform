import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
import { navModule } from './modules/nav';
import { acbThemeModule } from './themes';

export default createApp({
  features: [catalogPlugin, navModule, acbThemeModule],
});
