"use client";

import { toPng } from "html-to-image";
import {
  CSSProperties,
  ReactNode,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";

const IPHONE_W = 1320;
const IPHONE_H = 2868;
const ANDROID_W = 1080;
const ANDROID_H = 1920;
const FEATURE_W = 1024;
const FEATURE_H = 500;

const IPHONE_SIZES = [
  { label: '6.9"', w: 1320, h: 2868 },
  { label: '6.5"', w: 1284, h: 2778 },
  { label: '6.3"', w: 1206, h: 2622 },
  { label: '6.1"', w: 1125, h: 2436 },
] as const;
const ANDROID_SIZES = [{ label: "Phone", w: 1080, h: 1920 }] as const;

type Device = "iphone" | "android" | "feature";
type PhoneProps = {
  src: string;
  alt: string;
  style?: CSSProperties;
};
type CanvasProps = {
  cW: number;
  cH: number;
  phone: (props: PhoneProps) => ReactNode;
  base: string;
};
type Slide = {
  id: string;
  render: (props: CanvasProps) => ReactNode;
};

const IMAGE_PATHS = [
  "/mockup.png",
  "/app-icon.png",
  ...["home", "gallery-root", "spinkit", "charts"].flatMap(
    (name) => [
      `/screenshots/apple/iphone/en/${name}.png`,
      `/screenshots/android/phone/en/${name}.png`,
    ],
  ),
];
const imageCache: Record<string, string> = {};
const image = (path: string) => imageCache[path] || path;

async function preloadImages() {
  await Promise.all(
    IMAGE_PATHS.map(async (path) => {
      const response = await fetch(path);
      const blob = await response.blob();
      imageCache[path] = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.readAsDataURL(blob);
      });
    }),
  );
}

function IosStatusBar() {
  return (
    <div
      style={{
        position: "absolute",
        zIndex: 4,
        top: 18,
        left: 42,
        right: 60,
        height: 34,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        color: "#111827",
        fontSize: 24,
        fontWeight: 800,
        lineHeight: 1,
        pointerEvents: "none",
      }}
    >
      <span>9:41</span>
      <span style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <svg width="28" height="18" viewBox="0 0 28 18" aria-hidden="true">
          <rect x="1" y="12" width="4" height="5" rx="1" fill="currentColor" />
          <rect x="8" y="9" width="4" height="8" rx="1" fill="currentColor" />
          <rect x="15" y="5" width="4" height="12" rx="1" fill="currentColor" />
          <rect x="22" y="1" width="4" height="16" rx="1" fill="currentColor" />
        </svg>
        <svg width="27" height="20" viewBox="0 0 27 20" aria-hidden="true">
          <path
            d="M2 6.5C8.7.7 18.3.7 25 6.5M6.4 11c4-3.4 10.2-3.4 14.2 0M10.8 15.2c1.6-1.4 3.8-1.4 5.4 0"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.8"
            strokeLinecap="round"
          />
          <circle cx="13.5" cy="18" r="1.8" fill="currentColor" />
        </svg>
        <span
          style={{
            position: "relative",
            width: 31,
            height: 16,
            border: "3px solid #111827",
            borderRadius: 5,
          }}
        >
          <span
            style={{
              position: "absolute",
              inset: 2,
              borderRadius: 2,
              background: "#111827",
            }}
          />
          <span
            style={{
              position: "absolute",
              top: 3,
              right: -7,
              width: 4,
              height: 7,
              borderRadius: "0 2px 2px 0",
              background: "#111827",
            }}
          />
        </span>
      </span>
    </div>
  );
}

function Iphone({ src, alt, style }: PhoneProps) {
  const mkW = 1022;
  const mkH = 2082;
  return (
    <div style={{ position: "relative", aspectRatio: `${mkW}/${mkH}`, ...style }}>
      <img
        src={image("/mockup.png")}
        alt=""
        draggable={false}
        style={{ width: "100%", height: "100%", display: "block" }}
      />
      <div
        style={{
          position: "absolute",
          zIndex: 2,
          overflow: "hidden",
          left: `${(52 / mkW) * 100}%`,
          top: `${(46 / mkH) * 100}%`,
          width: `${(918 / mkW) * 100}%`,
          height: `${(1990 / mkH) * 100}%`,
          borderRadius: `${(126 / 918) * 100}% / ${(126 / 1990) * 100}%`,
        }}
      >
        <img
          src={image(src)}
          alt={alt}
          draggable={false}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: "top",
            display: "block",
          }}
        />
        <IosStatusBar />
      </div>
    </div>
  );
}

function AndroidPhone({ src, alt, style }: PhoneProps) {
  return (
    <div style={{ position: "relative", aspectRatio: "9/16", ...style }}>
      <div
        style={{
          position: "relative",
          width: "100%",
          height: "100%",
          overflow: "hidden",
          borderRadius: "7% / 4%",
          background: "linear-gradient(145deg,#34343a,#111114)",
          boxShadow:
            "inset 0 0 0 2px rgba(255,255,255,.12),0 35px 90px rgba(0,0,0,.6)",
        }}
      >
        <div
          style={{
            position: "absolute",
            zIndex: 5,
            top: "0.7%",
            left: "50%",
            width: "3.2%",
            aspectRatio: "1",
            borderRadius: "50%",
            transform: "translateX(-50%)",
            background: "#09090b",
          }}
        />
        <div
          style={{
            position: "absolute",
            left: "2%",
            top: "2%",
            width: "96%",
            height: "96%",
            overflow: "hidden",
            borderRadius: "5.5% / 3.2%",
            background: "#000",
          }}
        >
          <img
            src={image(src)}
            alt={alt}
            draggable={false}
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover",
              objectPosition: "top",
              display: "block",
            }}
          />
        </div>
      </div>
    </div>
  );
}

function Backdrop({
  cW,
  cH,
  children,
  variant = "violet",
}: {
  cW: number;
  cH: number;
  children: ReactNode;
  variant?: "violet" | "teal" | "ink" | "light";
}) {
  const gradients = {
    violet:
      "radial-gradient(circle at 18% 8%,#7c3aed55,transparent 28%),linear-gradient(155deg,#11131d 0%,#29203d 54%,#42275e 100%)",
    teal: "radial-gradient(circle at 88% 18%,#22d3ee42,transparent 30%),linear-gradient(150deg,#071b26,#0c5362 52%,#1b2948)",
    ink: "radial-gradient(circle at 50% 85%,#8b5cf650,transparent 28%),linear-gradient(160deg,#080a12,#111827 55%,#211b39)",
    light:
      "radial-gradient(circle at 90% 8%,#c4b5fd,transparent 30%),linear-gradient(155deg,#faf8ff,#e9e4f6 58%,#ddd6fe)",
  };
  return (
    <div
      style={{
        width: cW,
        height: cH,
        position: "relative",
        overflow: "hidden",
        background: gradients[variant],
        color: variant === "light" ? "#151323" : "#fff",
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          opacity: 0.16,
          backgroundImage:
            "linear-gradient(rgba(255,255,255,.1) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.1) 1px,transparent 1px)",
          backgroundSize: `${cW * 0.095}px ${cW * 0.095}px`,
          maskImage: "linear-gradient(to bottom,black,transparent 72%)",
        }}
      />
      {children}
    </div>
  );
}

function Caption({
  cW,
  label,
  children,
  dark = false,
}: {
  cW: number;
  label: string;
  children: ReactNode;
  dark?: boolean;
}) {
  return (
    <div
      style={{
        position: "absolute",
        zIndex: 10,
        top: cW * 0.13,
        left: cW * 0.07,
        right: cW * 0.07,
        textAlign: "center",
        color: dark ? "#171426" : "#fff",
      }}
    >
      <div
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: cW * 0.012,
          padding: `${cW * 0.011}px ${cW * 0.024}px`,
          borderRadius: 999,
          background: dark ? "rgba(91,33,182,.1)" : "rgba(255,255,255,.1)",
          border: `1px solid ${dark ? "rgba(91,33,182,.2)" : "rgba(255,255,255,.18)"}`,
          fontSize: cW * 0.025,
          fontWeight: 800,
          letterSpacing: "0.18em",
          textTransform: "uppercase",
        }}
      >
        {label}
      </div>
      <div
        style={{
          marginTop: cW * 0.035,
          fontSize: cW * 0.087,
          lineHeight: 0.98,
          letterSpacing: "-0.055em",
          fontWeight: 900,
          textTransform: "uppercase",
        }}
      >
        {children}
      </div>
    </div>
  );
}

function Device({
  phone,
  src,
  alt,
  cW,
  cH,
  style,
}: {
  phone: CanvasProps["phone"];
  src: string;
  alt: string;
  cW: number;
  cH: number;
  style?: CSSProperties;
}) {
  const { width: requestedWidth, ...placement } = style || {};
  const baseWidth =
    typeof requestedWidth === "number" ? requestedWidth : cW * 0.75;
  const adaptiveWidth = cH / cW < 2 ? baseWidth * 0.9 : baseWidth;

  return phone({
    src,
    alt,
    style: {
      position: "absolute",
      zIndex: 4,
      width: adaptiveWidth,
      filter: "drop-shadow(0 48px 48px rgba(0,0,0,.38))",
      ...placement,
    },
  });
}

const SLIDES: Slide[] = [
  {
    id: "home",
    render: ({ cW, cH, phone, base }) => (
      <Backdrop cW={cW} cH={cH} variant="violet">
        <Caption cW={cW} label="Ruflet Explorer">
          Ruby Anywhere
        </Caption>
        <div
          style={{
            position: "absolute",
            width: cW * 0.8,
            height: cW * 0.8,
            left: cW * 0.1,
            bottom: cH * 0.08,
            borderRadius: "50%",
            background: "radial-gradient(circle,#8b5cf677,transparent 68%)",
          }}
        />
        <Device
          cW={cW}
          cH={cH}
          phone={phone}
          src={`${base}/home.png`}
          alt="Ruflet Explorer home"
          style={{
            width: cW * 0.78,
            left: "50%",
            bottom: -cH * 0.1,
            transform: "translateX(-50%)",
          }}
        />
      </Backdrop>
    ),
  },
  {
    id: "gallery",
    render: ({ cW, cH, phone, base }) => (
      <Backdrop cW={cW} cH={cH} variant="ink">
        <Caption cW={cW} label="Built-in Gallery">
          Explore Every
          <br />
          Example
        </Caption>
        <Device
          cW={cW}
          cH={cH}
          phone={phone}
          src={`${base}/gallery-root.png`}
          alt="Ruflet example gallery"
          style={{
            width: cW * 0.78,
            left: "50%",
            bottom: -cH * 0.1,
            transform: "translateX(-50%)",
          }}
        />
      </Backdrop>
    ),
  },
  {
    id: "spinkit",
    render: ({ cW, cH, phone, base }) => (
      <Backdrop cW={cW} cH={cH} variant="teal">
        <Caption cW={cW} label="30 SpinKit Styles">
          Beautiful Loading
          <br />
          States
        </Caption>
        <Device
          cW={cW}
          cH={cH}
          phone={phone}
          src={`${base}/spinkit.png`}
          alt="Ruflet SpinKit gallery"
          style={{
            width: cW * 0.78,
            left: "50%",
            bottom: -cH * 0.1,
            transform: "translateX(-50%)",
          }}
        />
      </Backdrop>
    ),
  },
  {
    id: "charts",
    render: ({ cW, cH, phone, base }) => (
      <Backdrop cW={cW} cH={cH} variant="light">
        <Caption cW={cW} label="Data Visualization" dark>
          Charts That
          <br />
          Come Alive
        </Caption>
        <Device
          cW={cW}
          cH={cH}
          phone={phone}
          src={`${base}/charts.png`}
          alt="Ruflet charts"
          style={{
            width: cW * 0.78,
            left: "50%",
            bottom: -cH * 0.1,
            transform: "translateX(-50%)",
          }}
        />
      </Backdrop>
    ),
  },
];

function FeatureGraphic() {
  return (
    <div
      style={{
        width: FEATURE_W,
        height: FEATURE_H,
        position: "relative",
        overflow: "hidden",
        background:
          "radial-gradient(circle at 82% 38%,#22d3ee55,transparent 28%),radial-gradient(circle at 18% 110%,#8b5cf677,transparent 42%),linear-gradient(135deg,#080a12 0%,#15152a 58%,#2c1c4b 100%)",
        color: "#fff",
      }}
    >
      <div
        style={{
          position: "absolute",
          zIndex: 6,
          left: 60,
          top: 54,
          width: 520,
          display: "flex",
          alignItems: "center",
          gap: 15,
        }}
      >
        <img
          src={image("/app-icon.png")}
          alt="Ruflet Explorer"
          style={{
            width: 52,
            height: 52,
            borderRadius: 13,
            boxShadow: "0 14px 36px rgba(0,0,0,.45)",
          }}
        />
        <div
          style={{
            fontSize: 19,
            fontWeight: 850,
            letterSpacing: ".16em",
            textTransform: "uppercase",
          }}
        >
          Ruflet Explorer
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          zIndex: 6,
          left: 60,
          top: 128,
          width: 535,
          fontSize: 72,
          lineHeight: 0.87,
          fontWeight: 950,
          letterSpacing: "-.065em",
          textTransform: "uppercase",
        }}
      >
        Ruby
        <br />
        Anywhere
      </div>
      <div
        style={{
          position: "absolute",
          zIndex: 6,
          left: 62,
          top: 292,
          color: "#d8d4e8",
          fontSize: 21,
          fontWeight: 600,
        }}
      >
        Build native apps with Ruby.
      </div>
      <div
        style={{
          position: "absolute",
          zIndex: 5,
          right: 44,
          top: 72,
          width: 350,
          height: 354,
          overflow: "hidden",
          borderRadius: 27,
          transform: "rotate(2deg)",
          background: "rgba(5,10,20,.76)",
          border: "1px solid rgba(255,255,255,.15)",
          boxShadow: "0 36px 90px rgba(0,0,0,.48)",
          backdropFilter: "blur(18px)",
        }}
      >
        <div
          style={{
            height: 48,
            display: "flex",
            alignItems: "center",
            gap: 8,
            padding: "0 18px",
            background: "rgba(255,255,255,.07)",
            borderBottom: "1px solid rgba(255,255,255,.1)",
          }}
        >
          {["#fb7185", "#fbbf24", "#4ade80"].map((color) => (
            <span
              key={color}
              style={{ width: 10, height: 10, borderRadius: "50%", background: color }}
            />
          ))}
          <span
            style={{
              marginLeft: 10,
              color: "#b9bfd0",
              fontFamily: "var(--font-geist-mono),monospace",
              fontSize: 13,
            }}
          >
            main.rb
          </span>
        </div>
        <div
          style={{
            padding: "29px 28px",
            fontFamily: "var(--font-geist-mono),monospace",
            fontSize: 16,
            lineHeight: 1.75,
          }}
        >
          <div style={{ color: "#c4b5fd" }}>
            require <span style={{ color: "#86efac" }}>&quot;ruflet&quot;</span>
          </div>
          <div style={{ marginTop: 18, color: "#f8fafc" }}>
            <span style={{ color: "#c4b5fd" }}>Ruflet</span>.
            <span style={{ color: "#fbbf24" }}>run</span>{" "}
            <span style={{ color: "#7dd3fc" }}>do</span> |page|
          </div>
          <div style={{ paddingLeft: 20, color: "#f8fafc" }}>page.add(</div>
          <div style={{ paddingLeft: 40, color: "#86efac" }}>
            text(value: <span style={{ color: "#f8fafc" }}>&quot;Hello&quot;</span>)
          </div>
          <div style={{ paddingLeft: 20, color: "#f8fafc" }}>)</div>
          <div style={{ color: "#7dd3fc" }}>end</div>
        </div>
      </div>
    </div>
  );
}

function Preview({
  cW,
  cH,
  children,
}: {
  cW: number;
  cH: number;
  children: ReactNode;
}) {
  const width = 300;
  const scale = width / cW;
  return (
    <div
      style={{
        width,
        height: cH * scale,
        position: "relative",
        overflow: "hidden",
        borderRadius: 16,
        background: "#111",
        boxShadow: "0 18px 40px rgba(15,23,42,.16)",
      }}
    >
      <div
        style={{
          width: cW,
          height: cH,
          transform: `scale(${scale})`,
          transformOrigin: "top left",
        }}
      >
        {children}
      </div>
    </div>
  );
}

async function capture(el: HTMLElement, w: number, h: number) {
  el.style.left = "0px";
  el.style.opacity = "1";
  el.style.zIndex = "-1";
  const options = { width: w, height: h, pixelRatio: 1, cacheBust: true };
  await toPng(el, options);
  const result = await toPng(el, options);
  el.style.left = "-9999px";
  el.style.opacity = "";
  el.style.zIndex = "";
  return result;
}

export default function ScreenshotsPage() {
  const [ready, setReady] = useState(false);
  const [device, setDevice] = useState<Device>("iphone");
  const [sizeIndex, setSizeIndex] = useState(0);
  const [exporting, setExporting] = useState<string | null>(null);
  const exportRefs = useRef<Array<HTMLDivElement | null>>([]);

  useEffect(() => {
    preloadImages().then(() => setReady(true));
  }, []);

  const setup = useMemo(() => {
    if (device === "android") {
      return {
        cW: ANDROID_W,
        cH: ANDROID_H,
        sizes: ANDROID_SIZES,
        phone: AndroidPhone,
        base: "/screenshots/android/phone/en",
      };
    }
    if (device === "feature") {
      return {
        cW: FEATURE_W,
        cH: FEATURE_H,
        sizes: [{ label: "Feature Graphic", w: FEATURE_W, h: FEATURE_H }],
        phone: AndroidPhone,
        base: "",
      };
    }
    return {
      cW: IPHONE_W,
      cH: IPHONE_H,
      sizes: IPHONE_SIZES,
      phone: Iphone,
      base: "/screenshots/apple/iphone/en",
    };
  }, [device]);

  const canvases =
    device === "feature"
      ? [{ id: "google-play-feature", render: () => <FeatureGraphic /> }]
      : SLIDES;

  async function exportAll() {
    const size = setup.sizes[sizeIndex] || setup.sizes[0];
    for (let index = 0; index < canvases.length; index += 1) {
      const el = exportRefs.current[index];
      if (!el) continue;
      setExporting(`${index + 1}/${canvases.length}`);
      const png = await capture(el, size.w, size.h);
      const link = document.createElement("a");
      link.href = png;
      link.download = `${String(index + 1).padStart(2, "0")}-${canvases[index].id}-en-${size.w}x${size.h}.png`;
      link.click();
      await new Promise((resolve) => setTimeout(resolve, 300));
    }
    setExporting(null);
  }

  if (!ready) {
    return (
      <main style={{ padding: 48, fontFamily: "var(--font-geist-sans)" }}>
        Loading release artwork…
      </main>
    );
  }

  return (
    <main
      style={{
        minHeight: "100vh",
        position: "relative",
        overflowX: "hidden",
        background: "#eef0f5",
        color: "#171923",
        fontFamily: "var(--font-geist-sans),Arial,sans-serif",
      }}
    >
      <div
        style={{
          position: "sticky",
          top: 0,
          zIndex: 50,
          display: "flex",
          alignItems: "center",
          background: "rgba(255,255,255,.95)",
          borderBottom: "1px solid #dfe3ea",
          backdropFilter: "blur(16px)",
        }}
      >
        <div
          style={{
            flex: 1,
            minWidth: 0,
            display: "flex",
            alignItems: "center",
            gap: 12,
            padding: "12px 18px",
            overflowX: "auto",
          }}
        >
          <strong style={{ whiteSpace: "nowrap" }}>Ruflet Explorer · Release Art</strong>
          <div style={{ display: "flex", gap: 5, padding: 4, borderRadius: 10, background: "#eef0f5" }}>
            {(["iphone", "android", "feature"] as Device[]).map((item) => (
              <button
                key={item}
                onClick={() => {
                  setDevice(item);
                  setSizeIndex(0);
                }}
                style={{
                  border: 0,
                  borderRadius: 7,
                  padding: "7px 14px",
                  cursor: "pointer",
                  whiteSpace: "nowrap",
                  fontWeight: 700,
                  background: device === item ? "#fff" : "transparent",
                  color: device === item ? "#6d28d9" : "#6b7280",
                }}
              >
                {item === "iphone" ? "iPhone" : item === "android" ? "Android" : "Feature Graphic"}
              </button>
            ))}
          </div>
          {device !== "feature" && (
            <select
              value={sizeIndex}
              onChange={(event) => setSizeIndex(Number(event.target.value))}
              style={{
                padding: "7px 10px",
                border: "1px solid #d9dde5",
                borderRadius: 8,
                background: "#fff",
              }}
            >
              {setup.sizes.map((size, index) => (
                <option key={size.label} value={index}>
                  {size.label} — {size.w}×{size.h}
                </option>
              ))}
            </select>
          )}
        </div>
        <div style={{ flexShrink: 0, padding: "10px 16px", borderLeft: "1px solid #e5e7eb" }}>
          <button
            onClick={exportAll}
            disabled={Boolean(exporting)}
            style={{
              padding: "9px 20px",
              border: 0,
              borderRadius: 9,
              cursor: exporting ? "default" : "pointer",
              color: "#fff",
              background: exporting ? "#a78bfa" : "#6d28d9",
              fontWeight: 800,
            }}
          >
            {exporting ? `Exporting ${exporting}` : "Export All"}
          </button>
        </div>
      </div>

      <section
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(300px,1fr))",
          justifyItems: "center",
          gap: 24,
          padding: 28,
        }}
      >
        {canvases.map((slide) => (
          <Preview key={slide.id} cW={setup.cW} cH={setup.cH}>
            {slide.render({
              cW: setup.cW,
              cH: setup.cH,
              phone: setup.phone,
              base: setup.base,
            })}
          </Preview>
        ))}
      </section>

      <div style={{ position: "absolute", left: -9999, top: 0 }}>
        {canvases.map((slide, index) => (
          <div
            key={slide.id}
            ref={(element) => {
              exportRefs.current[index] = element;
            }}
            style={{
              position: "absolute",
              left: -9999,
              top: 0,
              width: setup.cW,
              height: setup.cH,
            }}
          >
            {slide.render({
              cW: setup.cW,
              cH: setup.cH,
              phone: setup.phone,
              base: setup.base,
            })}
          </div>
        ))}
      </div>
    </main>
  );
}
