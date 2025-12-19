"use client"
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { ArrowRight, BarChart2, Zap, ShieldCheck, TrendingUp, DollarSign, Package, Store, Database, Brain, Check, Star, Users, Sparkles, Activity, Target } from "lucide-react";
import { motion } from "framer-motion";

export default function LandingPage() {
  return (
    <div className="min-h-screen flex flex-col bg-white relative overflow-hidden">

      {/* Subtle Background Gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-50/30 via-white to-indigo-50/20 pointer-events-none" />
      <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-gradient-to-br from-blue-100/20 to-indigo-100/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 left-0 w-[500px] h-[500px] bg-gradient-to-tr from-purple-100/20 to-pink-100/10 rounded-full blur-3xl pointer-events-none" />

      {/* Navbar - Glass Morphism */}
      <nav className="sticky top-0 z-50 backdrop-blur-xl bg-white/70 border-b border-gray-200/50">
        <div className="flex items-center justify-between px-6 lg:px-8 py-6 max-w-7xl mx-auto w-full">
          <div className="flex items-center gap-3">
            <div className="relative h-24 w-64">
              <Image
                src="/pasale.jpg"
                alt="Pasale Logo"
                fill
                className="object-contain"
                priority
              />
            </div>
          </div>
          <div className="hidden md:flex items-center gap-12">
            <Link href="#features" className="text-xl font-bold text-gray-600 hover:text-gray-900 transition-colors">Features</Link>
            <Link href="#how-it-works" className="text-xl font-bold text-gray-600 hover:text-gray-900 transition-colors">How it works</Link>
            <Link href="#pricing" className="text-xl font-bold text-gray-600 hover:text-gray-900 transition-colors">Pricing</Link>
          </div>
          <div className="flex items-center gap-8">
            <Link href="/login">
              <Button variant="ghost" className="text-xl font-bold">Log in</Button>
            </Link>
            <Link href="/login">
              <Button className="rounded-full bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 shadow-lg shadow-green-500/25 text-xl font-bold px-6 py-6">
                Get Started
                <ArrowRight className="ml-2 h-6 w-6" />
              </Button>
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="flex-1 flex flex-col items-center px-4 lg:px-8 z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          className="max-w-6xl w-full text-center mt-8 lg:mt-12 mb-8"
        >

          {/* Headline */}
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-green-600 leading-tight mb-4">
            AI-Powered Retail Sales Insights
          </h1>

          {/* Subheadline */}
          <p className="text-base sm:text-lg text-slate-600 max-w-2xl mx-auto leading-relaxed mb-6 font-normal">
            Get advanced AI insights and accurate forecasting. Subscribe to unlock data-driven growth and predictive analytics for your company.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col items-center gap-6">
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link href="/login">
                <Button className="group rounded-lg h-12 px-6 text-base font-bold bg-teal-600 hover:bg-teal-700 text-white shadow-lg hover:shadow-xl transition-all duration-300">
                  Get Started - Dashboard
                  <ArrowRight className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform" />
                </Button>
              </Link>
              <Link href="#pricing">
                <Button variant="outline" className="rounded-lg h-12 px-6 text-base font-bold border-2 border-slate-200 text-slate-700 hover:border-slate-300 hover:bg-slate-50 transition-all">
                  View Pricing
                </Button>
              </Link>
            </div>
          </div>
        </motion.div>

        {/* Core Features Section */}
        <section id="features" className="w-full max-w-7xl mx-auto py-8 lg:py-12 bg-gradient-to-b from-gray-50/50 to-white rounded-3xl">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="px-4 lg:px-8"
          >
            <div className="text-center mb-16 py-8">
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-teal-600">
                What Can You Get From Us
              </h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
              <FeatureCard
                icon={<Brain className="h-7 w-7" />}
                gradient="from-purple-500 to-indigo-600"
                title="AI Sales Predictions"
                desc="Forecast daily, weekly, and monthly sales using advanced machine learning algorithms."
              />
              <FeatureCard
                icon={<DollarSign className="h-7 w-7" />}
                gradient="from-green-500 to-emerald-600"
                title="Price–Demand Impact"
                desc="Test new prices and instantly see predicted quantity, revenue, and price sensitivity."
              />
              <FeatureCard
                icon={<Package className="h-7 w-7" />}
                gradient="from-blue-500 to-cyan-600"
                title="New Product Forecast"
                desc="Predict expected sales for new items using similar product trends and patterns."
              />
              <FeatureCard
                icon={<BarChart2 className="h-7 w-7" />}
                gradient="from-indigo-500 to-purple-600"
                title="Dashboard Analytics"
                desc="Track sales, categories, shop performance, heatmaps, and emerging trends."
              />
              <FeatureCard
                icon={<TrendingUp className="h-7 w-7" />}
                gradient="from-orange-500 to-red-600"
                title="Best Sellers & Slow Movers"
                desc="Identify what to restock, what to promote, and what needs discounting."
              />
              <FeatureCard
                icon={<Store className="h-7 w-7" />}
                gradient="from-pink-500 to-rose-600"
                title="Shop & Location Insights"
                desc="Compare performance across multiple Kathmandu locations in real-time."
              />
            </div>

            {/* Statistics */}
            <div className="flex flex-wrap items-center justify-center gap-20 mt-24 mb-8">
              <div className="flex items-center gap-4">
                <Database className="h-10 w-10 text-teal-600" />
                <span className="text-slate-900 font-bold text-3xl">50M+ Data Points</span>
              </div>
              <div className="flex items-center gap-4">
                <ShieldCheck className="h-10 w-10 text-teal-600" />
                <span className="text-slate-900 font-bold text-3xl">24/7 Support</span>
              </div>
              <div className="flex items-center gap-4">
                <Activity className="h-10 w-10 text-teal-600" />
                <span className="text-slate-900 font-bold text-3xl">99.9% Uptime</span>
              </div>
            </div>
          </motion.div>
        </section>

        {/* How It Works Section */}
        <section id="how-it-works" className="w-full max-w-7xl mx-auto py-20 lg:py-32">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="px-4 lg:px-8"
          >
            <div className="text-center mb-16 lg:mb-20">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-indigo-50 border border-indigo-200/50 mb-4"
              >
                <Zap className="h-4 w-4 text-indigo-600" />
                <span className="text-sm font-semibold text-indigo-700">Simple Process</span>
              </motion.div>
              <h2 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-4">
                How पसले Works
              </h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto font-light">
                Three simple steps to transform your retail business
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12 relative">
              {/* Connection Lines */}
              <div className="hidden md:block absolute top-16 left-0 right-0 h-0.5 bg-gradient-to-r from-blue-200 via-indigo-200 to-purple-200" style={{ width: 'calc(100% - 6rem)', left: '3rem' }} />

              <HowItWorksCard
                step="1"
                title="Your POS data stays internal"
                description="We connect securely to your internal PostgreSQL sales database with enterprise-grade encryption."
                icon={<Database className="h-10 w-10" />}
                gradient="from-blue-500 to-cyan-600"
                delay={0}
              />
              <HowItWorksCard
                step="2"
                title="पसले analyzes everything"
                description="AI models read your sales patterns, pricing history, and category behavior in real-time."
                icon={<Brain className="h-10 w-10" />}
                gradient="from-indigo-500 to-purple-600"
                delay={0.2}
              />
              <HowItWorksCard
                step="3"
                title="You get instant results"
                description="Insights appear on your dashboard — no uploads, no manual work, just smart decisions."
                icon={<Zap className="h-10 w-10" />}
                gradient="from-purple-500 to-pink-600"
                delay={0.4}
              />
            </div>
          </motion.div>
        </section>

        {/* Pricing Section */}
        <section id="pricing" className="w-full max-w-7xl mx-auto py-20 lg:py-32">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="px-4 lg:px-8"
          >
            <div className="text-center mb-16 lg:mb-20">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-50 border border-green-200/50 mb-4"
              >
                <DollarSign className="h-4 w-4 text-green-600" />
                <span className="text-sm font-semibold text-green-700">Simple Pricing</span>
              </motion.div>
              <h2 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-4">
                Plans That Scale With You
              </h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto font-light">Choose the perfect plan for your business size and needs</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-6 max-w-6xl mx-auto">
              <PricingCard
                tier="Starter"
                price="NPR 15,000"
                period="/year"
                badge=""
                tagline="For small shopkeepers"
                features={[
                  "Dashboard access",
                  "Daily sales summary",
                  "Category insights",
                  "Top 5 best sellers",
                  "Email support"
                ]}
                ctaText="Get Started"
                ctaLink="/dashboard"
              />
              <PricingCard
                tier="Growth"
                price="NPR 50,000"
                period="/year"
                badge=""
                tagline="Ideal for growing businesses"
                popular={true}
                features={[
                  "Everything in Free",
                  "AI demand forecasting",
                  "Price–demand modeling",
                  "New product predictions",
                  "Revenue projections",
                  "Detailed heatmaps",
                  "Unlimited access"
                ]}
                ctaText="Start Pro Trial"
                ctaLink="/dashboard"
              />
              <PricingCard
                tier="Enterprise"
                price="NPR 1,500,000"
                period="/year"
                badge=""
                tagline="For large retailers"
                features={[
                  "Custom dashboards",
                  "API integration",
                  "Multi-shop analytics",
                  "Dedicated support",
                  "Priority features",
                  "Custom training"
                ]}
                ctaText="Contact Sales"
                ctaLink="/dashboard"
              />
            </div>
            <div className="text-center mt-12">
              <Link href="#pricing">
                <Button variant="outline" size="lg" className="rounded-full">
                  Compare Plans
                </Button>
              </Link>
            </div>
          </motion.div>
        </section>

        {/* Testimonials Section */}
        <section className="w-full max-w-7xl mx-auto py-20 lg:py-32 bg-gradient-to-b from-white to-gray-50/50 rounded-3xl">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="px-4 lg:px-8"
          >
            <div className="text-center mb-16 lg:mb-20">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-yellow-50 border border-yellow-200/50 mb-4"
              >
                <Star className="h-4 w-4 text-yellow-600" />
                <span className="text-sm font-semibold text-yellow-700">Customer Stories</span>
              </motion.div>
              <h2 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-4">
                Loved by <span className="bg-gradient-to-r from-teal-600 to-blue-600 bg-clip-text text-transparent">Startups and FMCG</span> Across Nepal
              </h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto font-light">See how पसले is transforming retail businesses</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
              <TestimonialCard
                quote="पसले's demand forecasting helped us optimize inventory across 200+ stores in Nepal."
                author="Unilever Nepal"
                location="Kathmandu"
              />
              <TestimonialCard
                quote="The AI-driven price optimization increased our profit margins by 18% within 3 months."
                author="Unilever Nepal"
                location="Distribution Center"
              />
              <TestimonialCard
                quote="As a startup, पसले gave us enterprise-level insights. Sales predictions are 95% accurate!"
                author="FreshMart Organics"
                location="Lalitpur"
              />
            </div>
          </motion.div>
        </section>

        {/* Final CTA Section */}
        <section className="w-full max-w-7xl mx-auto py-20 lg:py-32 px-4 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="relative overflow-hidden bg-gradient-to-br from-blue-600 via-indigo-600 to-purple-700 rounded-3xl lg:rounded-[2.5rem] p-12 lg:p-20 text-center shadow-2xl"
          >
            {/* Decorative Elements */}
            <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl" />
            <div className="absolute bottom-0 left-0 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl" />

            <div className="relative z-10">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ delay: 0.2, duration: 0.5 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/20 backdrop-blur-sm border border-white/30 mb-6"
              >
                <Sparkles className="h-4 w-4 text-white" />
                <span className="text-sm font-semibold text-white">Start Free Today</span>
              </motion.div>

              <h2 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                Ready to Grow Your Shop<br />with AI?
              </h2>
              <p className="text-lg lg:text-xl text-blue-100 mb-10 max-w-2xl mx-auto font-light">
                No data uploads. पसले uses your existing internal database.<br />
                <span className="font-semibold text-white">Get started in under 5 minutes.</span>
              </p>
              <Link href="/login">
                <Button size="lg" className="group rounded-full h-16 px-10 text-lg font-semibold bg-white text-blue-600 hover:bg-gray-50 shadow-2xl hover:shadow-3xl hover:scale-105 transition-all duration-300">
                  Get Started — It's Free
                  <ArrowRight className="ml-2 h-6 w-6 group-hover:translate-x-1 transition-transform" />
                </Button>
              </Link>
              <p className="text-sm text-blue-100 mt-6">No credit card required  •  Setup in 5 minutes  •  Cancel anytime</p>
            </div>
          </motion.div>
        </section>
      </main>

      {/* Footer */}
      <footer className="relative z-10 border-t border-gray-200 bg-white/50 backdrop-blur-sm mt-20">
        <div className="max-w-7xl mx-auto px-4 lg:px-8 py-20">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-14 mb-12">
            {/* Brand */}
            <div className="md:col-span-2">
              <div className="relative h-16 w-40 mb-4">
                <Image
                  src="/pasale.jpg"
                  alt="Pasale Logo"
                  fill
                  className="object-contain"
                />
              </div>
              <p className="text-lg text-gray-600 mb-4 max-w-sm">
                AI-powered retail intelligence for Nepal. Transform your POS data into actionable insights.
              </p>
              <div className="flex gap-4">
                <Link href="#" className="h-12 w-12 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors">
                  <span className="sr-only">Twitter</span>
                  <svg className="h-6 w-6 text-gray-600" fill="currentColor" viewBox="0 0 24 24"><path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" /></svg>
                </Link>
              </div>
            </div>

            {/* Links */}
            <div>
              <h4 className="font-bold text-gray-900 mb-4 text-lg">Product</h4>
              <ul className="space-y-3.5">
                <li><Link href="#features" className="text-base text-gray-600 hover:text-gray-900 transition-colors">Features</Link></li>
                <li><Link href="#pricing" className="text-base text-gray-600 hover:text-gray-900 transition-colors">Pricing</Link></li>
                <li><Link href="/dashboard" className="text-base text-gray-600 hover:text-gray-900 transition-colors">Dashboard</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold text-gray-900 mb-4 text-lg">Company</h4>
              <ul className="space-y-3.5">
                <li><Link href="#" className="text-base text-gray-600 hover:text-gray-900 transition-colors">About</Link></li>
                <li><Link href="#" className="text-base text-gray-600 hover:text-gray-900 transition-colors">Contact</Link></li>
                <li><Link href="/login" className="text-base text-gray-600 hover:text-gray-900 transition-colors">Login</Link></li>
              </ul>
            </div>
          </div>

          <div className="pt-8 border-t border-gray-200">
            <div className="flex flex-col md:flex-row justify-between items-center gap-4">
              <p className="text-base text-gray-600">
                © 2024 पसले Inc. All rights reserved.
              </p>
              <div className="flex gap-6 text-base">
                <Link href="#" className="text-gray-600 hover:text-gray-900 transition-colors">Privacy</Link>
                <Link href="#" className="text-gray-600 hover:text-gray-900 transition-colors">Terms</Link>
                <Link href="#" className="text-gray-600 hover:text-gray-900 transition-colors">Security</Link>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, desc, gradient }: { icon: React.ReactNode, title: string, desc: string, gradient: string }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5 }}
      className="group relative p-8 rounded-2xl bg-white border border-gray-200/50 shadow-sm hover:shadow-xl hover:border-gray-300 transition-all duration-300 hover:-translate-y-1"
    >
      <div className={`mb-5 h-14 w-14 rounded-xl bg-gradient-to-br ${gradient} shadow-lg flex items-center justify-center text-white group-hover:scale-110 group-hover:rotate-3 transition-all duration-300`}>
        {icon}
      </div>
      <h3 className="text-xl font-bold text-gray-900 mb-3">{title}</h3>
      <p className="text-gray-600 leading-relaxed">{desc}</p>

      {/* Hover Effect */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-blue-50/0 to-indigo-50/0 group-hover:from-blue-50/50 group-hover:to-indigo-50/30 transition-all duration-300 pointer-events-none" />
    </motion.div>
  )
}

function HowItWorksCard({ step, title, description, icon, gradient, delay }: { step: string, title: string, description: string, icon: React.ReactNode, gradient: string, delay: number }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ delay, duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
      className="relative p-8 lg:p-10 rounded-2xl bg-white border border-gray-200/50 shadow-lg hover:shadow-xl text-center group transition-all duration-300 hover:-translate-y-2"
    >
      <div className={`absolute -top-6 left-1/2 -translate-x-1/2 h-14 w-14 rounded-2xl bg-gradient-to-br ${gradient} text-white flex items-center justify-center text-2xl font-bold shadow-xl group-hover:scale-110 group-hover:rotate-6 transition-all duration-300`}>
        {step}
      </div>
      <div className="mt-6 mb-6 flex justify-center text-white">
        <div className={`p-4 rounded-xl bg-gradient-to-br ${gradient} shadow-lg`}>
          {icon}
        </div>
      </div>
      <h3 className="text-xl lg:text-2xl font-bold text-gray-900 mb-4">{title}</h3>
      <p className="text-gray-600 leading-relaxed">{description}</p>
    </motion.div>
  )
}

function PricingCard({ tier, price, period, badge, tagline, features, ctaText, ctaLink, popular }: {
  tier: string,
  price: string,
  period: string,
  badge: string,
  tagline: string,
  features: string[],
  ctaText: string,
  ctaLink: string,
  popular?: boolean
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5 }}
      className={`relative p-8 lg:p-10 rounded-3xl bg-white border-2 shadow-lg hover:shadow-2xl transition-all duration-300 ${popular
        ? 'border-indigo-500 ring-4 ring-indigo-100 scale-105 lg:scale-110'
        : 'border-gray-200 hover:border-gray-300'
        }`}
    >
      {popular && (
        <div className="absolute -top-5 left-1/2 -translate-x-1/2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-2 rounded-full text-sm font-bold shadow-lg">
          Most Popular
        </div>
      )}
      <div className="text-center mb-8">
        {badge && <div className="text-5xl mb-4">{badge}</div>}
        <h3 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-2">{tier}</h3>
        <p className="text-sm text-gray-600 mb-6">{tagline}</p>
        <div className="mb-6">
          <span className="text-5xl lg:text-6xl font-bold text-gray-900">{price}</span>
          {period && <span className="text-lg text-gray-600 font-medium">{period}</span>}
        </div>
      </div>
      <ul className="space-y-4 mb-8">
        {features.map((feature, i) => (
          <motion.li
            key={i}
            initial={{ opacity: 0, x: -10 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ delay: i * 0.1, duration: 0.3 }}
            className="flex items-start gap-3"
          >
            <div className="h-6 w-6 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0 mt-0.5">
              <Check className="h-4 w-4 text-green-600" />
            </div>
            <span className="text-gray-700 font-medium">{feature}</span>
          </motion.li>
        ))}
      </ul>
      <Link href={ctaLink}>
        <Button className={`w-full rounded-full h-12 font-semibold transition-all duration-300 ${popular
          ? 'bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 shadow-lg shadow-indigo-500/30'
          : 'bg-gray-900 hover:bg-gray-800'
          }`}>
          {ctaText}
          <ArrowRight className="ml-2 h-4 w-4" />
        </Button>
      </Link>
    </motion.div>
  )
}

function TestimonialCard({ quote, author, location }: { quote: string, author: string, location: string }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5 }}
      className="group p-8 lg:p-10 rounded-2xl bg-white border border-gray-200/50 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
    >
      <div className="flex gap-1 mb-6">
        {[1, 2, 3, 4, 5].map((i) => (
          <Star key={i} className="h-5 w-5 fill-yellow-400 text-yellow-400" />
        ))}
      </div>
      <p className="text-lg lg:text-xl text-gray-700 mb-8 leading-relaxed">"{quote}"</p>
      <div className="flex items-center gap-4">
        <div className="h-14 w-14 rounded-full bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-white font-bold text-xl shadow-lg group-hover:scale-110 transition-transform">
          {author[0]}
        </div>
        <div>
          <p className="font-bold text-gray-900 text-lg">{author}</p>
          <p className="text-sm text-gray-600 flex items-center gap-1">
            <span className="h-1.5 w-1.5 rounded-full bg-blue-600" />
            {location}
          </p>
        </div>
      </div>
    </motion.div>
  )
}
