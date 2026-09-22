const COOKIE_NAME = "af_auth";
const MAX_AGE_SECONDS = 60 * 60 * 24 * 30; // 30 jours

async function sign(value, secret) {
	const enc = new TextEncoder();
	const key = await crypto.subtle.importKey(
		"raw",
		enc.encode(secret),
		{ name: "HMAC", hash: "SHA-256" },
		false,
		["sign"],
	);
	const sigBuf = await crypto.subtle.sign("HMAC", key, enc.encode(value));
	return [...new Uint8Array(sigBuf)]
		.map((b) => b.toString(16).padStart(2, "0"))
		.join("");
}

function timingSafeEqual(a, b) {
	if (a.length !== b.length) return false;
	let result = 0;
	for (let i = 0; i < a.length; i++) result |= a.charCodeAt(i) ^ b.charCodeAt(i);
	return result === 0;
}

async function verifyCookie(cookieHeader, secret) {
	if (!cookieHeader) return false;
	const match = cookieHeader.match(new RegExp(`(?:^|; )${COOKIE_NAME}=([^;]+)`));
	if (!match) return false;
	const [expStr, sig] = decodeURIComponent(match[1]).split(".");
	if (!expStr || !sig) return false;
	const exp = Number(expStr);
	if (!Number.isFinite(exp) || Date.now() > exp) return false;
	const expected = await sign(expStr, secret);
	return timingSafeEqual(expected, sig);
}

export async function onRequest(context) {
	const { request, env, next } = context;
	const url = new URL(request.url);

	if (!env.SITE_PASSWORD || !env.AUTH_SECRET) {
		return new Response(
			"Configuration serveur manquante : les secrets SITE_PASSWORD et AUTH_SECRET doivent être définis dans les paramètres du projet Cloudflare Pages.",
			{ status: 500 },
		);
	}

	const isLoginPage =
		url.pathname === "/login" ||
		url.pathname === "/login/" ||
		url.pathname === "/login/index.html";

	if (isLoginPage && request.method === "POST") {
		const form = await request.formData();
		const password = form.get("password")?.toString() ?? "";

		if (timingSafeEqual(password, env.SITE_PASSWORD)) {
			const exp = Date.now() + MAX_AGE_SECONDS * 1000;
			const sig = await sign(String(exp), env.AUTH_SECRET);
			const cookieValue = encodeURIComponent(`${exp}.${sig}`);
			return new Response(null, {
				status: 302,
				headers: {
					Location: "/",
					"Set-Cookie": `${COOKIE_NAME}=${cookieValue}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=${MAX_AGE_SECONDS}`,
				},
			});
		}

		return Response.redirect(`${url.origin}/login/?error=1`, 302);
	}

	if (isLoginPage) {
		return next();
	}

	const authed = await verifyCookie(request.headers.get("Cookie"), env.AUTH_SECRET);
	if (!authed) {
		return Response.redirect(`${url.origin}/login/`, 302);
	}

	return next();
}
