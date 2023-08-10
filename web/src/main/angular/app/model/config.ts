import {IOAuthConfig} from './oauth-config';
import {ExternalWebsiteConfig} from './external-website-config';

export interface IConfig {
  apiUrl: string;
  getHelpUrl?: string;
  oauth?: IOAuthConfig;
  logoPath?: string;
  faviconName?: string;
  about?: ExternalWebsiteConfig;
  github?: ExternalWebsiteConfig;
}
