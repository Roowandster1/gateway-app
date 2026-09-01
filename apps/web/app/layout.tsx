import type { Metadata } from "next";
import { Archivo } from "next/font/google";
import "./globals.css";

/**
 * Archivo is loaded with its width axis, not at fixed weights. Every price a
 * shopper reads at a glance is set condensed and heavy, the way a shelf-edge
 * ticket is printed; without the axis that silently falls back to a normal-width
 * face and the whole type system quietly stops working.
 */
const archivo = Archivo({
  variable: "--font-archivo",
  subsets: ["latin"],
  axes: ["wdth"],
  weight: "variable",
});

export const metadata: Metadata = {
  title: "Till Total",
  description:
    "A week of meals and a shopping list that costs what the app says it will.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en-GB"
      className={`${archivo.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
