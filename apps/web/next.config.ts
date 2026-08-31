import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /**
   * Next's dev server rejects asset requests whose origin it does not recognise,
   * which 403s every chunk when the app is opened on 127.0.0.1 rather than
   * localhost — the page renders but never hydrates, so nothing responds to a
   * click. Both spellings are allowed so either works in local dev.
   */
  allowedDevOrigins: ["127.0.0.1", "localhost"],
};

export default nextConfig;
