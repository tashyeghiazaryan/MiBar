import { useEffect, useRef, useState } from "react";

type IconName =
  | "arrow"
  | "back"
  | "bookmark"
  | "bookmarked"
  | "calendar"
  | "check"
  | "close"
  | "headphones"
  | "heart"
  | "home"
  | "pause"
  | "play"
  | "spark"
  | "widget"
  | "chevronDown";

type Screen = "language" | "email" | "otp" | "loading" | "app";
type Tab = "today" | "archive" | "favorites";
type AppLanguage = "en" | "ru" | "hy";

const LANGUAGES: Array<{
  id: AppLanguage;
  native: string;
  label: string;
  sample: string;
}> = [
  { id: "en", native: "English", label: "English", sample: "One word a day" },
  { id: "ru", native: "Русский", label: "Russian", sample: "Одно слово в день" },
  { id: "hy", native: "Հայերեն", label: "Armenian", sample: "Մեկ բառ ամեն օր" },
];

type PartOfSpeech = "noun" | "verb" | "adjective" | "adverb";

const POS_LABEL: Record<PartOfSpeech, string> = {
  noun: "գոյական · noun · сущ.",
  verb: "բայ · verb · гл.",
  adjective: "ածական · adj. · прил.",
  adverb: "մակբայ · adv. · нар.",
};

const POS_STYLE: Record<PartOfSpeech, { background: string; color: string }> = {
  noun: { background: "#0d1846", color: "#ffffff" },
  verb: { background: "#406eb7", color: "#ffffff" },
  adjective: { background: "#e95623", color: "#ffffff" },
  adverb: { background: "#cfcfcf", color: "#000000" },
};

type Word = {
  id: number;
  armenian: string;
  transliteration: string;
  english: string;
  russian: string;
  date: string;
  phrase: string;
  phraseTransliteration: string;
  phraseEnglish: string;
  phraseRussian: string;
  pos: PartOfSpeech;
  note?: string;
};

const WORDS: Word[] = [
  {
    id: 1,
    armenian: "Լույս",
    transliteration: "luys",
    english: "light",
    russian: "свет",
    date: "June 24",
    phrase: "Բարի լույս, Երևա՛ն։",
    phraseTransliteration: "bari luys, Yerevan",
    phraseEnglish: "Good morning, Yerevan!",
    phraseRussian: "Доброе утро, Ереван!",
    pos: "noun",
    note: "“Բարի լույս” literally means “good light” — it’s how people wish each other a good morning in Armenia.",
  },
  {
    id: 2,
    armenian: "Ջան",
    transliteration: "jan",
    english: "dear",
    russian: "дорогой, милая",
    date: "June 23",
    phrase: "Անի ջան, ինչպե՞ս ես։",
    phraseTransliteration: "Ani jan, inchpes es?",
    phraseEnglish: "Ani jan, how are you?",
    phraseRussian: "Ани-джан, как ты?",
    pos: "adjective",
    note: "A warm term of affection placed after the name of someone dear to you.",
  },
  {
    id: 3,
    armenian: "Տուն",
    transliteration: "tun",
    english: "home",
    russian: "дом",
    date: "June 22",
    phrase: "Ես գնում եմ տուն։",
    phraseTransliteration: "yes gnum em tun",
    phraseEnglish: "I am going home.",
    phraseRussian: "Я иду домой.",
    pos: "noun",
  },
  {
    id: 4,
    armenian: "Արև",
    transliteration: "arev",
    english: "sun",
    russian: "солнце",
    date: "June 21",
    phrase: "Այսօր արև կա։",
    phraseTransliteration: "aysor arev ka",
    phraseEnglish: "There is sun today.",
    phraseRussian: "Сегодня солнечно.",
    pos: "noun",
    note: "The sun is one of the oldest and most recognizable symbols in Armenian culture.",
  },
  {
    id: 5,
    armenian: "Սիրել",
    transliteration: "sirel",
    english: "to love",
    russian: "любить",
    date: "June 20",
    phrase: "Ես սիրում եմ Երևանը։",
    phraseTransliteration: "yes sirum em Yerevany",
    phraseEnglish: "I love Yerevan.",
    phraseRussian: "Я люблю Ереван.",
    pos: "verb",
  },
  {
    id: 6,
    armenian: "Ընկեր",
    transliteration: "ynker",
    english: "friend",
    russian: "друг",
    date: "June 19",
    phrase: "Նա իմ լավ ընկերն է։",
    phraseTransliteration: "na im lav ynkern e",
    phraseEnglish: "He is my good friend.",
    phraseRussian: "Он мой хороший друг.",
    pos: "noun",
  },
  {
    id: 7,
    armenian: "Լավ",
    transliteration: "lav",
    english: "well",
    russian: "хорошо",
    date: "June 18",
    phrase: "Ես լավ եմ։",
    phraseTransliteration: "yes lav em",
    phraseEnglish: "I am well.",
    phraseRussian: "У меня всё хорошо.",
    pos: "adverb",
  },
];

function Icon({ name, size = 22 }: { name: IconName; size?: number }) {
  const common = {
    width: size,
    height: size,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    "aria-hidden": true,
  };
  const paths: Record<IconName, React.ReactNode> = {
    arrow: <><path d="M5 12h14" /><path d="m14 7 5 5-5 5" /></>,
    back: <><path d="m15 18-6-6 6-6" /></>,
    bookmark: <path d="M6.5 4.8A1.8 1.8 0 0 1 8.3 3h7.4a1.8 1.8 0 0 1 1.8 1.8V21L12 17.5 6.5 21Z" />,
    bookmarked: <path fill="currentColor" d="M6.5 4.8A1.8 1.8 0 0 1 8.3 3h7.4a1.8 1.8 0 0 1 1.8 1.8V21L12 17.5 6.5 21Z" />,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M16 3v4M8 3v4M3 10h18" /></>,
    check: <path d="m5 12 4 4L19 6" />,
    close: <><path d="m6 6 12 12M18 6 6 18" /></>,
    headphones: <><path d="M4 14a8 8 0 0 1 16 0" /><path d="M4 14v4a2 2 0 0 0 2 2h1v-7H6a2 2 0 0 0-2 1ZM20 14v4a2 2 0 0 1-2 2h-1v-7h1a2 2 0 0 1 2 1Z" /></>,
    heart: <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z" />,
    home: <><path d="m3 11 9-8 9 8" /><path d="M5 10v10h14V10M9 20v-6h6v6" /></>,
    pause: <><path d="M9 8v8M15 8v8" /></>,
    play: <path fill="currentColor" stroke="none" d="m9 7 8 5-8 5Z" />,
    spark: <><path d="m12 3 1.4 4.1L17.5 8.5l-4.1 1.4L12 14l-1.4-4.1-4.1-1.4 4.1-1.4Z" /><path d="m18.5 15 .7 2.3 2.3.7-2.3.7-.7 2.3-.7-2.3-2.3-.7 2.3-.7Z" /></>,
    widget: <><rect x="3" y="3" width="8" height="8" rx="1.5" /><rect x="13" y="3" width="8" height="8" rx="1.5" /><rect x="3" y="13" width="8" height="8" rx="1.5" /><rect x="13" y="13" width="8" height="8" rx="1.5" /></>,
    chevronDown: <><path d="m6 9 6 6 6-6" /></>,
  };
  return <svg {...common}>{paths[name]}</svg>;
}

function Button({
  children,
  onClick,
  variant = "primary",
  disabled = false,
  label,
  className = "",
}: {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: "primary" | "text" | "icon" | "circle";
  disabled?: boolean;
  label?: string;
  className?: string;
}) {
  return (
    <button
      aria-label={label}
      className={`button button--${variant} ${className}`}
      disabled={disabled}
      onClick={onClick}
      type="button"
    >
      {children}
    </button>
  );
}

function BrandMark({ compact = false, showMark = true }: { compact?: boolean; showMark?: boolean }) {
  return (
    <div className={`brand ${compact ? "brand--compact" : ""} ${!showMark ? "brand--text-only" : ""}`}>
      {showMark && (
        <div className="brand__sun" aria-hidden="true">
          <span>Մ</span>
        </div>
      )}
      <div className="brand__name">MiBar</div>
      {!compact && <div className="brand__armenian">մի բառ · one word</div>}
    </div>
  );
}

type FloatLetter = {
  id: string;
  char: string;
  scatterX: number;
  scatterY: number;
  targetX: number;
  targetY: number;
  size: number;
  color: string;
  drift: number;
};

const WORD_LINES = [
  { text: "Սեր", color: "var(--blue)", meaning: "love", x: 22, y: 22, spacing: 13, size: 28 },
  { text: "Լույս", color: "var(--blue)", meaning: "light", x: 68, y: 48, spacing: 11, size: 24 },
  { text: "Սիրուն", color: "var(--blue)", meaning: "beauty", x: 38, y: 78, spacing: 10, size: 22 },
] as const;

function buildFloatLetters(): FloatLetter[] {
  const letters: FloatLetter[] = [];
  WORD_LINES.forEach((word, wordIndex) => {
    const chars = Array.from(word.text);
    const startX = word.x - ((chars.length - 1) * word.spacing) / 2;

    chars.forEach((char, index) => {
      const seed = wordIndex * 17 + index * 13;
      letters.push({
        id: `${wordIndex}-${index}`,
        char,
        scatterX: 8 + ((seed * 37) % 84),
        scatterY: 6 + ((seed * 53) % 88),
        targetX: startX + index * word.spacing,
        targetY: word.y,
        size: word.size,
        color: word.color,
        drift: (seed % 7) + 3,
      });
    });
  });
  return letters;
}

const FLOAT_LETTERS = buildFloatLetters();

function lerp(a: number, b: number, t: number) {
  return a + (b - a) * t;
}

function LetterConstellation() {
  const [tilt, setTilt] = useState({ x: 0, y: 0 });
  const [tick, setTick] = useState(0);
  const listening = useRef(false);
  const fieldRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    let frame = 0;
    const animate = (time: number) => {
      setTick(time);
      frame = window.requestAnimationFrame(animate);
    };
    frame = window.requestAnimationFrame(animate);
    return () => window.cancelAnimationFrame(frame);
  }, []);

  useEffect(() => {
    const onOrientation = (event: DeviceOrientationEvent) => {
      const gamma = event.gamma ?? 0;
      const beta = event.beta ?? 45;
      setTilt({
        x: Math.max(-1, Math.min(1, gamma / 28)),
        y: Math.max(-1, Math.min(1, (beta - 45) / 40)),
      });
    };

    const onMouse = (event: MouseEvent) => {
      if (listening.current) return;
      const field = fieldRef.current;
      if (!field) return;
      const rect = field.getBoundingClientRect();
      const x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
      const y = ((event.clientY - rect.top) / rect.height) * 2 - 1;
      setTilt({
        x: Math.max(-1, Math.min(1, x)),
        y: Math.max(-1, Math.min(1, y)),
      });
    };

    window.addEventListener("deviceorientation", onOrientation);
    window.addEventListener("mousemove", onMouse);
    return () => {
      window.removeEventListener("deviceorientation", onOrientation);
      window.removeEventListener("mousemove", onMouse);
    };
  }, []);

  const enableMotion = async () => {
    const orientation = DeviceOrientationEvent as unknown as {
      requestPermission?: () => Promise<"granted" | "denied">;
    };
    if (typeof orientation.requestPermission === "function") {
      try {
        const result = await orientation.requestPermission();
        listening.current = result === "granted";
      } catch {
        listening.current = false;
      }
    } else {
      listening.current = true;
    }
  };

  const formation = Math.min(1, Math.abs(tilt.x) * 1.35);
  const ease = formation * formation * (3 - 2 * formation);

  return (
    <div
      aria-hidden="true"
      className="letter-field"
      onPointerDown={enableMotion}
      ref={fieldRef}
    >
      <div className="letter-field__hint">
        {ease > 0.55 ? "սեր · լույս · սիրուն" : "tilt to form words"}
      </div>
      {FLOAT_LETTERS.map((letter) => {
        const wave = Math.sin(tick / 700 + letter.drift) * (1 - ease) * 4;
        const x = lerp(letter.scatterX, letter.targetX, ease) + tilt.x * letter.drift * (1 - ease * 0.4);
        const y = lerp(letter.scatterY, letter.targetY, ease) + tilt.y * (letter.drift * 0.6) + wave;
        return (
          <span
            className={`letter-float ${ease > 0.7 ? "letter-float--formed" : ""}`}
            key={letter.id}
            style={{
              left: `${x}%`,
              top: `${y}%`,
              color: letter.color,
              fontSize: `${letter.size}px`,
              opacity: 0.28 + ease * 0.62,
              transform: `translate(-50%, -50%) rotate(${(1 - ease) * (letter.drift - 5) * 4}deg)`,
            }}
          >
            {letter.char}
          </span>
        );
      })}
    </div>
  );
}

function LanguageScreen({
  value,
  onContinue,
}: {
  value: AppLanguage;
  onContinue: (language: AppLanguage) => void;
}) {
  const [selected, setSelected] = useState<AppLanguage>(value);

  return (
    <main className="onboarding language-screen">
      <div className="onboarding__content">
        <BrandMark showMark={false} />
        <div className="language-intro">
          <div className="eyebrow">Welcome</div>
          <div className="display-title">Choose your<br />language</div>
          <p className="body-copy">Pick the language for menus, buttons, and everyday guidance. You can change it later.</p>
        </div>
        <div className="language-list" role="radiogroup" aria-label="Interface language">
          {LANGUAGES.map((language) => {
            const active = selected === language.id;
            return (
              <button
                aria-checked={active}
                className={`language-option ${active ? "language-option--active" : ""}`}
                key={language.id}
                onClick={() => setSelected(language.id)}
                role="radio"
                type="button"
              >
                <span className="language-option__copy">
                  <span className="language-option__native">{language.native}</span>
                  <span className="language-option__sample">{language.sample}</span>
                </span>
                <span className={`language-option__check ${active ? "language-option__check--on" : ""}`}>
                  {active && <Icon name="check" size={18} />}
                </span>
              </button>
            );
          })}
        </div>
        <div className="language-actions">
          <Button onClick={() => onContinue(selected)}>
            <span>Continue</span>
            <Icon name="arrow" />
          </Button>
        </div>
      </div>
    </main>
  );
}

type LoadLetter = {
  id: string;
  char: string;
  scatterX: number;
  scatterY: number;
  targetX: number;
  targetY: number;
  size: number;
  isExtra: boolean;
};

function buildLoadLetters(word: string, extras: string[], size: number, slot = 7.1): LoadLetter[] {
  const chars = Array.from(word);
  const width = (chars.length - 1) * slot;
  const startX = 50 - width / 2;

  const wordLetters = chars.map((char, order) => {
    const seed = order * 19 + char.charCodeAt(0);
    return {
      id: `${word}-${order}`,
      char,
      scatterX: 30 + ((seed * 41) % 40),
      scatterY: 32 + ((seed * 67) % 36),
      targetX: startX + order * slot,
      targetY: 50,
      size,
      isExtra: false,
    };
  });

  const extraLetters = extras.map((char, order) => {
    const seed = order * 23 + char.charCodeAt(0) + 11;
    return {
      id: `${word}-extra-${order}`,
      char,
      scatterX: 26 + ((seed * 37) % 48),
      scatterY: 28 + ((seed * 53) % 44),
      targetX: 22 + ((seed * 29) % 56),
      targetY: 18 + ((seed * 31) % 14) + (order % 2) * 58,
      size: Math.round(size * 0.7),
      isExtra: true,
    };
  });

  return [...wordLetters, ...extraLetters];
}

const LOAD_MIBAR = buildLoadLetters("MiBar", ["A", "r", "e", "v", "s", "o", "n", "u", "y", "l", "t"], 36, 4.6);

function clamp01(value: number) {
  return Math.max(0, Math.min(1, value));
}

function smoothstep(value: number) {
  const t = clamp01(value);
  return t * t * (3 - 2 * t);
}

function loadingFormation(elapsed: number) {
  if (elapsed < 220) return 0;
  if (elapsed < 1100) return smoothstep((elapsed - 220) / 880);
  return 1;
}

function HomeLoadingScreen({ onDone }: { onDone: () => void }) {
  const [elapsed, setElapsed] = useState(0);
  const onDoneRef = useRef(onDone);
  const startRef = useRef(0);
  const finishedRef = useRef(false);
  onDoneRef.current = onDone;

  useEffect(() => {
    startRef.current = performance.now();
    let frame = 0;
    const tick = (now: number) => {
      const next = now - startRef.current;
      setElapsed(next);
      if (next >= 2400) {
        if (!finishedRef.current) {
          finishedRef.current = true;
          onDoneRef.current();
        }
        return;
      }
      frame = window.requestAnimationFrame(tick);
    };
    frame = window.requestAnimationFrame(tick);
    return () => window.cancelAnimationFrame(frame);
  }, []);

  const formation = loadingFormation(elapsed);
  const exiting = elapsed >= 1750;
  const exitProgress = smoothstep((elapsed - 1750) / 650);

  return (
    <main
      className={`home-loading ${exiting ? "home-loading--exit" : ""}`}
      aria-live="polite"
      style={{ opacity: exiting ? 1 - exitProgress : 1 }}
    >
      <div className="home-loading__stage">
        {LOAD_MIBAR.map((letter, index) => {
          const wave = Math.sin(elapsed / 420 + index) * (1 - formation) * 4;
          const gather = letter.isExtra ? formation * 0.15 : formation;
          const x = lerp(letter.scatterX, letter.targetX, gather);
          const y = lerp(letter.scatterY, letter.targetY, gather) + wave;
          const opacity = letter.isExtra
            ? Math.max(0, 0.4 * (1 - formation * 1.15))
            : 0.4 + formation * 0.6;
          return (
            <span
              className="home-loading__letter"
              key={letter.id}
              style={{
                left: `${x}%`,
                top: `${y}%`,
                fontSize: `${letter.size}px`,
                opacity,
                transform: `translate(-50%, -50%) rotate(${(1 - gather) * (index % 2 === 0 ? -14 : 14)}deg)`,
              }}
            >
              {letter.char}
            </span>
          );
        })}
      </div>
    </main>
  );
}

function EmailScreen({ onContinue }: { onContinue: (email: string) => void }) {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [touched, setTouched] = useState(false);
  const valid = email === "1111" || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

  const submit = () => {
    setTouched(true);
    if (!valid) return;
    setLoading(true);
    window.setTimeout(() => onContinue(email), 650);
  };

  return (
    <main className="onboarding">
      <div className="onboarding__content">
        <BrandMark showMark={false} />
        <LetterConstellation />
        <div className="intro">
          <div className="eyebrow">Armenian, every day</div>
          <div className="display-title">One word.<br />A whole world.</div>
          <p className="body-copy">Discover the living Armenian language through words, stories, and culture.</p>
        </div>
        <div className="form">
          <label className="field-label" htmlFor="email">Your email</label>
          <input
            id="email"
            autoComplete="email"
            className={`field ${touched && !valid ? "field--error" : ""}`}
            onBlur={() => setTouched(true)}
            onChange={(event) => setEmail(event.target.value)}
            onKeyDown={(event) => event.key === "Enter" && submit()}
            placeholder="name@example.com"
            type="email"
            value={email}
          />
          {touched && !valid && <div className="field-message">Enter a valid email address or 1111</div>}
          <Button disabled={loading} onClick={submit}>
            {loading ? <span className="loader" /> : <><span>Continue</span><Icon name="arrow" /></>}
          </Button>
        </div>
        <p className="fine-print">Use 1111 for prototype access, or continue with your email.</p>
      </div>
    </main>
  );
}

function OtpScreen({
  email,
  onBack,
  onSuccess,
}: {
  email: string;
  onBack: () => void;
  onSuccess: () => void;
}) {
  const [digits, setDigits] = useState(["", "", "", ""]);
  const [status, setStatus] = useState<"idle" | "loading" | "error" | "success">("idle");
  const [resent, setResent] = useState(false);
  const inputs = useRef<Array<HTMLInputElement | null>>([]);

  const updateDigit = (index: number, value: string) => {
    const digit = value.replace(/\D/g, "").slice(-1);
    const next = [...digits];
    next[index] = digit;
    setDigits(next);
    if (status === "error") setStatus("idle");
    if (digit && index < 3) inputs.current[index + 1]?.focus();
    if (next.every(Boolean)) verify(next.join(""));
  };

  const verify = (code: string) => {
    setStatus("loading");
    window.setTimeout(() => {
      if (code === "1111") {
        setStatus("success");
        window.setTimeout(onSuccess, 700);
      } else {
        setStatus("error");
      }
    }, 700);
  };

  const handleKey = (index: number, event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Backspace" && !digits[index] && index > 0) inputs.current[index - 1]?.focus();
  };

  const focusField = (index = 0) => {
    const target = inputs.current[index];
    if (!target) return;
    target.focus();
    target.click();
  };

  useEffect(() => {
    const timer = window.setTimeout(() => focusField(0), 80);
    return () => window.clearTimeout(timer);
  }, []);

  const resend = () => {
    setResent(true);
    setDigits(["", "", "", ""]);
    setStatus("idle");
    focusField(0);
    window.setTimeout(() => setResent(false), 3000);
  };

  const focusNextEmpty = () => {
    const emptyIndex = digits.findIndex((digit) => !digit);
    focusField(emptyIndex === -1 ? 0 : emptyIndex);
  };

  return (
    <main className="otp-screen">
      <div className="top-action">
        <Button label="Back" onClick={onBack} variant="icon"><Icon name="back" /></Button>
        <BrandMark compact showMark={false} />
        <div className="top-action__spacer" />
      </div>
      <div className="otp-content">
        <div className="eyebrow">Almost there</div>
        <div className="section-title">Check your inbox</div>
        <p className="body-copy">We sent a four-digit code to<br /><strong>{email === "1111" ? "your prototype inbox" : email}</strong></p>
        <Button onClick={onBack} variant="text">Change email</Button>
        <div
          className={`otp ${status === "error" ? "otp--error" : ""} ${status === "success" ? "otp--success" : ""}`}
          onClick={focusNextEmpty}
        >
          {digits.map((digit, index) => (
            <input
              aria-label={`Digit ${index + 1}`}
              autoComplete={index === 0 ? "one-time-code" : "off"}
              autoFocus={index === 0}
              className="otp__digit"
              enterKeyHint="done"
              inputMode="numeric"
              key={index}
              maxLength={1}
              onChange={(event) => updateDigit(index, event.target.value)}
              onFocus={(event) => event.currentTarget.select()}
              onKeyDown={(event) => handleKey(index, event)}
              pattern="[0-9]*"
              ref={(node) => { inputs.current[index] = node; }}
              type="tel"
              value={digit}
            />
          ))}
        </div>
        <div className="otp-status" aria-live="polite">
          {status === "loading" && <><span className="loader loader--dark" /> Checking code…</>}
          {status === "error" && <span className="status-error">That code didn’t work. Try again.</span>}
          {status === "success" && <span className="status-success"><Icon name="check" size={18} /> All set! Opening MiBar…</span>}
          {status === "idle" && <span className="demo-code">Prototype code: <strong>1111</strong></span>}
        </div>
        <Button disabled={resent} onClick={resend} variant="text">
          {resent ? "New code sent" : "Send code again"}
        </Button>
      </div>
    </main>
  );
}

type WidgetStyle = "classic" | "soft" | "sun" | "clear";

const WIDGET_STYLES: Array<{ id: WidgetStyle; name: string; hint: string }> = [
  { id: "classic", name: "Classic", hint: "Deep navy" },
  { id: "soft", name: "Soft", hint: "Light paper" },
  { id: "sun", name: "Sun", hint: "Warm orange" },
  { id: "clear", name: "Clear", hint: "Wallpaper shows" },
];

function WidgetPreview({
  word,
  style = "classic",
}: {
  word: Word;
  style?: WidgetStyle;
}) {
  return (
    <div
      aria-hidden="true"
      className={`widget-preview widget-preview--${style}`}
    >
      <div className="widget-preview__kicker">Word of the day</div>
      <div className="widget-preview__armenian">{word.armenian}</div>
      <div className="widget-preview__meta">[{word.transliteration}]</div>
      <div className="widget-preview__translation">{word.english} · {word.russian}</div>
    </div>
  );
}

function WidgetHowTo({
  word,
  selected,
  onSelect,
  onClose,
}: {
  word: Word;
  selected: WidgetStyle;
  onSelect: (style: WidgetStyle) => void;
  onClose: () => void;
}) {
  const scrollerRef = useRef<HTMLDivElement | null>(null);
  const selectedMeta = WIDGET_STYLES.find((item) => item.id === selected);

  useEffect(() => {
    const scroller = scrollerRef.current;
    if (!scroller) return;
    const index = WIDGET_STYLES.findIndex((item) => item.id === selected);
    const card = scroller.children[index] as HTMLElement | undefined;
    if (!card) return;
    scroller.scrollTo({
      left: card.offsetLeft - (scroller.clientWidth - card.clientWidth) / 2,
      behavior: "auto",
    });
  }, []);

  const handleScroll = () => {
    const scroller = scrollerRef.current;
    if (!scroller) return;
    const center = scroller.scrollLeft + scroller.clientWidth / 2;
    let closest = 0;
    let closestDistance = Number.POSITIVE_INFINITY;
    Array.from(scroller.children).forEach((child, index) => {
      const el = child as HTMLElement;
      const mid = el.offsetLeft + el.clientWidth / 2;
      const distance = Math.abs(mid - center);
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = index;
      }
    });
    const next = WIDGET_STYLES[closest]?.id;
    if (next && next !== selected) onSelect(next);
  };

  return (
    <div className="widget-sheet" role="dialog" aria-modal="true" aria-label="Choose widget style">
      <button className="widget-sheet__backdrop" onClick={onClose} type="button" aria-label="Close" />
      <div className="widget-sheet__panel">
        <div className="widget-sheet__handle" />
        <div className="widget-sheet__header">
          <div>
            <div className="eyebrow">Home Screen</div>
            <div className="widget-sheet__title">Choose your widget</div>
          </div>
          <Button label="Close" onClick={onClose} variant="icon"><Icon name="close" size={18} /></Button>
        </div>
        <p className="widget-sheet__lead">
          Swipe left to preview styles. Then add your favorite from the Home Screen.
        </p>
        <div
          aria-label="Widget styles"
          className="widget-carousel"
          onScroll={handleScroll}
          ref={scrollerRef}
          role="radiogroup"
        >
          {WIDGET_STYLES.map((item) => {
            const active = selected === item.id;
            return (
              <button
                aria-checked={active}
                className={`widget-carousel__card ${active ? "widget-carousel__card--active" : ""}`}
                key={item.id}
                onClick={() => {
                  onSelect(item.id);
                  const scroller = scrollerRef.current;
                  const index = WIDGET_STYLES.findIndex((entry) => entry.id === item.id);
                  const card = scroller?.children[index] as HTMLElement | undefined;
                  card?.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
                }}
                role="radio"
                type="button"
              >
                <WidgetPreview word={word} style={item.id} />
                <span className="widget-carousel__name">{item.name}</span>
                <span className="widget-carousel__hint">{item.hint}</span>
              </button>
            );
          })}
        </div>
        <div className="widget-carousel__dots" aria-hidden="true">
          {WIDGET_STYLES.map((item) => (
            <span
              className={`widget-carousel__dot ${selected === item.id ? "widget-carousel__dot--active" : ""}`}
              key={item.id}
            />
          ))}
        </div>
        <div className="widget-howto">
          <div className="widget-howto__title">How to add</div>
          <p className="widget-howto__text">
            Apps can’t place a widget for you. Follow the steps below to put{" "}
            <strong>{selectedMeta?.name}</strong> on your Home Screen.
          </p>
        </div>
        <div className="widget-steps">
          <div className="widget-steps__group">
            <div className="widget-steps__label">iPhone</div>
            <ol>
              <li>Touch and hold the Home Screen</li>
              <li>Tap <strong>Edit</strong> → <strong>Add Widget</strong></li>
              <li>Find <strong>MiBar</strong> and choose <strong>{selectedMeta?.name}</strong></li>
              <li>Tap <strong>Add Widget</strong></li>
            </ol>
          </div>
          <div className="widget-steps__group">
            <div className="widget-steps__label">Android</div>
            <ol>
              <li>Touch and hold the Home Screen</li>
              <li>Tap <strong>Widgets</strong></li>
              <li>Find <strong>MiBar · {selectedMeta?.name}</strong></li>
              <li>Drag the widget onto your screen</li>
            </ol>
          </div>
        </div>
        <Button onClick={onClose}>
          <span>Got it</span>
          <Icon name="check" />
        </Button>
      </div>
    </div>
  );
}

function WidgetPromo({ word }: { word: Word }) {
  const [open, setOpen] = useState(false);
  const [style, setStyle] = useState<WidgetStyle>("classic");

  return (
    <>
      <section className="widget-promo">
        <div className="widget-promo__copy">
          <div className="section-label">Home Screen</div>
          <div className="widget-promo__title">Keep today’s word on your Home Screen</div>
          <p>Choose a widget style, then add it — one Armenian word every day, without opening the app.</p>
          <Button className="widget-promo__button" onClick={() => setOpen(true)} variant="text">
            <Icon name="widget" size={18} />
            <span>Choose style</span>
            <Icon name="arrow" size={18} />
          </Button>
        </div>
        <WidgetPreview word={word} style={style} />
      </section>
      {open && (
        <WidgetHowTo
          word={word}
          selected={style}
          onSelect={setStyle}
          onClose={() => setOpen(false)}
        />
      )}
    </>
  );
}

function WordFeature({
  word,
  saved,
  onToggleSave,
  isDetail = false,
  onBack,
  onLogout,
}: {
  word: Word;
  saved: boolean;
  onToggleSave: () => void;
  isDetail?: boolean;
  onBack?: () => void;
  onLogout?: () => void;
}) {
  const [playing, setPlaying] = useState(false);
  const [showScrollHint, setShowScrollHint] = useState(!isDetail);
  const pageRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!playing) return;
    const timer = window.setTimeout(() => setPlaying(false), 2300);
    return () => window.clearTimeout(timer);
  }, [playing]);

  useEffect(() => {
    if (isDetail) return;
    const page = pageRef.current;
    const scroller = page?.closest(".app-scroll") as HTMLElement | null;
    if (!scroller) return;

    const onScroll = () => {
      if (scroller.scrollTop > 24) setShowScrollHint(false);
    };

    scroller.addEventListener("scroll", onScroll, { passive: true });
    return () => scroller.removeEventListener("scroll", onScroll);
  }, [isDetail]);

  const scrollToMore = () => {
    const page = pageRef.current;
    const scroller = page?.closest(".app-scroll") as HTMLElement | null;
    const phrase = page?.querySelector(".phrase-block") as HTMLElement | null;
    if (!scroller || !phrase) return;
    scroller.scrollTo({ top: phrase.offsetTop - 12, behavior: "smooth" });
    setShowScrollHint(false);
  };

  return (
    <div className={`word-page ${!isDetail ? "word-page--home" : ""}`} ref={pageRef}>
      <div className="word-topbar">
        {isDetail ? (
          <Button label="Back to the list" onClick={onBack} variant="icon"><Icon name="back" /></Button>
        ) : (
          <BrandMark compact showMark={false} />
        )}
        <div className="word-topbar__end">
          <div className="word-topbar__date">
            <span>{isDetail ? word.date : "TUESDAY · JUNE 24"}</span>
            <span className="today-dot" />
          </div>
          {!isDetail && onLogout && (
            <Button className="logout-button" onClick={onLogout} variant="text">
              Log out
            </Button>
          )}
        </div>
      </div>

      <section className="hero-word">
        <div className="hero-word__kicker">{isDetail ? "From the archive" : "Word of the day"} <span>No. {108 + word.id}</span></div>
        <div className="armenian-word">{word.armenian}</div>
        <div className="word-meta">
          <span className="transliteration">[{word.transliteration}]</span>
          <span className="word-meta__rule" />
          <span className="word-meta__translation">{word.english}</span>
          <span className="word-meta__dot">·</span>
          <span className="word-meta__translation">{word.russian}</span>
        </div>
        <div className="word-actions">
          <Button
            className={playing ? "audio-button--playing" : ""}
            label={playing ? "Stop pronunciation" : "Play pronunciation"}
            onClick={() => setPlaying(!playing)}
            variant="circle"
          >
            <Icon name={playing ? "pause" : "play"} />
            {playing && <span className="audio-ripple" />}
          </Button>
          <div className="listen-label">{playing ? "Playing…" : "Listen"}</div>
          <Button
            className={saved ? "save-button--active" : ""}
            label={saved ? "Remove from favorites" : "Save to favorites"}
            onClick={onToggleSave}
            variant="circle"
          >
            <Icon name={saved ? "bookmarked" : "bookmark"} />
          </Button>
          <div className="listen-label">{saved ? "Saved" : "Save"}</div>
        </div>
        {!isDetail && showScrollHint && (
          <button className="scroll-hint" onClick={scrollToMore} type="button">
            <span>Scroll for more</span>
            <Icon name="chevronDown" size={18} />
          </button>
        )}
      </section>

      <section className="phrase-block">
        <div className="section-label">Say it today</div>
        <div className="phrase-armenian">{word.phrase}</div>
        <div className="phrase-transliteration">[{word.phraseTransliteration}]</div>
        <div className="phrase-english">{word.phraseEnglish}</div>
        <div className="phrase-russian">{word.phraseRussian}</div>
      </section>

      {word.note && (
        <section className="culture-note">
          <div className="culture-note__mark"><Icon name="spark" /></div>
          <div>
            <div className="section-label">Between the lines</div>
            <p>{word.note}</p>
          </div>
        </section>
      )}

      {!isDetail && (
        <>
          <div className="tomorrow-note">
            <span className="tomorrow-note__line" />
            A new word tomorrow at 9:00
            <span className="tomorrow-note__line" />
          </div>
          <WidgetPromo word={word} />
        </>
      )}
    </div>
  );
}

function Archive({
  onOpen,
  savedIds,
  onToggleSave,
}: {
  onOpen: (word: Word) => void;
  savedIds: number[];
  onToggleSave: (id: number) => void;
}) {
  return (
    <div className="list-page">
      <header className="page-header page-header--archive">
        <div>
          <div className="eyebrow">Growing, one word at a time</div>
          <div className="page-title">All words</div>
          <p className="page-subline">Tap any word and try saying it</p>
        </div>
        <div className="word-count" aria-label={`${WORDS.length} words`}>
          <strong>{WORDS.length}</strong>
          <span>words</span>
        </div>
      </header>
      <div className="month-label"><span>June 2025</span><span className="month-label__line" /></div>
      <div className="word-list">
        {WORDS.map((word, index) => (
          <div className="word-row" key={word.id}>
            <Button className="word-row__main" label={`Open ${word.armenian}`} onClick={() => onOpen(word)} variant="text">
              <span className="word-row__date">{word.date.split(" ")[1]}</span>
              <span className="word-row__copy">
                <span className="word-row__armenian">{word.armenian}</span>
                <span className="word-row__translation">{word.english} · {word.russian}</span>
              </span>
              <span className="word-row__arrow"><Icon name="arrow" size={19} /></span>
            </Button>
            <Button
              className="word-row__save"
              label={savedIds.includes(word.id) ? "Remove from favorites" : "Save"}
              onClick={() => onToggleSave(word.id)}
              variant="icon"
            >
              <Icon name={savedIds.includes(word.id) ? "bookmarked" : "bookmark"} size={19} />
            </Button>
            {index === 0 && <span className="latest-label">today</span>}
          </div>
        ))}
      </div>
    </div>
  );
}

function Favorites({
  savedIds,
  onOpen,
  onRemove,
}: {
  savedIds: number[];
  onOpen: (word: Word) => void;
  onRemove: (id: number) => void;
}) {
  const savedWords = WORDS.filter((word) => savedIds.includes(word.id));
  return (
    <div className="list-page favorites-page">
      <header className="page-header">
        <div>
          <div className="eyebrow">Words worth keeping</div>
          <div className="page-title">Favorites</div>
        </div>
        {savedWords.length > 0 && <div className="word-count"><strong>{savedWords.length}</strong><span>saved</span></div>}
      </header>
      {savedWords.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state__symbol" aria-hidden="true">
            <Icon name="bookmark" size={30} />
            <span>Ա</span>
          </div>
          <div className="empty-state__title">Your words will<br />live here</div>
          <p>Tap the bookmark beside a word to return to it whenever you like.</p>
          <div className="empty-state__armenian">հիշել · to remember</div>
        </div>
      ) : (
        <div className="favorite-grid">
          {savedWords.map((word) => (
            <article
              className={`favorite-card favorite-card--${word.pos}`}
              key={word.id}
              style={POS_STYLE[word.pos]}
            >
              <Button className="favorite-card__open" label={`Open ${word.armenian}`} onClick={() => onOpen(word)} variant="text">
                <span className="favorite-card__number">{POS_LABEL[word.pos]}</span>
                <span className="favorite-card__armenian">{word.armenian}</span>
                <span className="favorite-card__translation">{word.english} · {word.russian}</span>
              </Button>
              <Button label={`Remove ${word.armenian}`} onClick={() => onRemove(word.id)} variant="icon">
                <Icon name="close" size={18} />
              </Button>
            </article>
          ))}
        </div>
      )}
    </div>
  );
}

function TabBar({ active, onChange }: { active: Tab; onChange: (tab: Tab) => void }) {
  const tabs: Array<{ id: Tab; label: string; icon: IconName }> = [
    { id: "today", label: "Today", icon: "home" },
    { id: "archive", label: "All words", icon: "calendar" },
    { id: "favorites", label: "Favorites", icon: "heart" },
  ];
  return (
    <nav className="tab-bar" aria-label="Main navigation">
      {tabs.map((tab) => (
        <Button
          className={`tab ${active === tab.id ? "tab--active" : ""}`}
          key={tab.id}
          label={tab.label}
          onClick={() => onChange(tab.id)}
          variant="text"
        >
          <span className="tab__icon"><Icon name={tab.icon} size={21} /></span>
          <span>{tab.label}</span>
        </Button>
      ))}
    </nav>
  );
}

function MainApp({ onLogout }: { onLogout: () => void }) {
  const [tab, setTab] = useState<Tab>("today");
  const [savedIds, setSavedIds] = useState<number[]>([1, 5, 2, 7]);
  const [detail, setDetail] = useState<Word | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => setReady(true));
    return () => window.cancelAnimationFrame(frame);
  }, []);

  const toggleSaved = (id: number) => {
    setSavedIds((current) => current.includes(id) ? current.filter((savedId) => savedId !== id) : [...current, id]);
  };

  const changeTab = (next: Tab) => {
    setDetail(null);
    setTab(next);
  };

  const openDetail = (word: Word) => setDetail(word);

  return (
    <main className={`app-shell ${ready ? "app-shell--enter" : ""}`}>
      <div className="app-scroll">
        {detail ? (
          <WordFeature
            isDetail
            onBack={() => setDetail(null)}
            onToggleSave={() => toggleSaved(detail.id)}
            saved={savedIds.includes(detail.id)}
            word={detail}
          />
        ) : (
          <>
            {tab === "today" && (
              <WordFeature
                onLogout={onLogout}
                onToggleSave={() => toggleSaved(1)}
                saved={savedIds.includes(1)}
                word={WORDS[0]}
              />
            )}
            {tab === "archive" && <Archive onOpen={openDetail} onToggleSave={toggleSaved} savedIds={savedIds} />}
            {tab === "favorites" && <Favorites onOpen={openDetail} onRemove={toggleSaved} savedIds={savedIds} />}
          </>
        )}
      </div>
      {!detail && <TabBar active={tab} onChange={changeTab} />}
    </main>
  );
}

export default function App() {
  const [screen, setScreen] = useState<Screen>("email");
  const [language, setLanguage] = useState<AppLanguage>("en");
  const [email, setEmail] = useState("");

  return (
    <div className="stage" data-language={language}>
      <div className="phone-frame">
        <div className="dynamic-island" aria-hidden="true" />
        {screen === "email" && (
          <EmailScreen
            onContinue={(nextEmail) => {
              setEmail(nextEmail);
              setScreen("otp");
            }}
          />
        )}
        {screen === "otp" && (
          <OtpScreen
            email={email}
            onBack={() => setScreen("email")}
            onSuccess={() => setScreen("language")}
          />
        )}
        {screen === "language" && (
          <LanguageScreen
            value={language}
            onContinue={(nextLanguage) => {
              setLanguage(nextLanguage);
              setScreen("loading");
            }}
          />
        )}
        {screen === "loading" && (
          <HomeLoadingScreen onDone={() => setScreen("app")} />
        )}
        {screen === "app" && (
          <MainApp
            onLogout={() => {
              setEmail("");
              setScreen("email");
            }}
          />
        )}
      </div>
    </div>
  );
}
