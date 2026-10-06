export default function Home() {
	const appName = process.env.HOSTNAME
  
	return (
		<main>
			<h1>Bienvenue sur mon application</h1>
			<p>Cette page Next.js provient du pod: {appName} .</p>
		</main>
	);
}
