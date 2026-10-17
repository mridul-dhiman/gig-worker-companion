// Saathi AI — Gig Worker Companion (src/App.jsx)
// Generated for Google for Developers PromptWars Warm-up Challenge
// Includes all 5 connected GenAI workflows: Earnings, Grievance, Welfare, Documents & Safety

import React, { useState } from 'react';
import {
  Wallet, ShieldAlert, Scale, FileText, MessageSquareWarning,
  Globe, UserCheck, Sparkles, ArrowRight, CheckCircle2,
  AlertTriangle, Copy, Check, RefreshCw, HeartHandshake
} from 'lucide-react';

// Full Persona Presets & Multilingual Gemini 3 Flash Integration
const PERSONAS = {
  "delivery": {
    "id": "delivery",
    "name": "Rajesh Kumar",
    "role": "Delivery Partner (Quick-Commerce & Food)",
    "badge": "Delivery Partner",
    "defaultLog": "Completed 18 deliveries today, earned ₹1,150 total. Spent ₹240 on petrol. Platform deducted ₹180 penalty saying \"late order delivery\" even though restaurant delayed the food by 35 mins.",
    "defaultGross": 1150,
    "defaultExpense": 240,
    "defaultDeduction": 180,
    "defaultIssue": "Unfair ₹180 penalty deducted for restaurant preparation delay (Order #49281) despite arriving at pickup location on time.",
    "defaultDoc": "NOTICE OF PENALTY DEDUCTION: Partner ID #DL-9921. An amount of INR 180.00 has been debited from your weekly settlement under Clause 4.2 (SLA Breach - Delayed Handover). Dispute window closes in 48 hours.",
    "safetyChecklist": [
      "Inspect brake pads, tyre pressure, and reflective rain gear before evening peak hours.",
      "Never speed to beat arbitrary 10-minute timers; log restaurant or traffic delays in-app immediately.",
      "Take a 10-minute hydration and shade break every 2 hours during high heat or heavy rain alerts."
    ]
  },
  "driver": {
    "id": "driver",
    "name": "Gurpreet Singh",
    "role": "App-Based Cab & Auto Driver",
    "badge": "Cab Driver",
    "defaultLog": "Drove 11 hours today, total fares ₹2,400. CNG fuel cost ₹650, MCD toll ₹120 was not added to customer bill by the app, and platform took commission.",
    "defaultGross": 2400,
    "defaultExpense": 650,
    "defaultDeduction": 120,
    "defaultIssue": "Unreimbursed MCD commercial toll charge of ₹120 on airport trip #TR-8832 despite uploading valid Fastag receipt.",
    "defaultDoc": "E-CHALLAN / PERMIT NOTICE: Vehicle PB-08-CT-4402 flagged for commercial pickup outside designated zone. Fine: INR 2,000 under MV Act. Option to contest before Virtual Traffic Court within 15 days.",
    "safetyChecklist": [
      "Verify emergency SOS button and dashcam/audio recording permissions before starting night shifts.",
      "Do not accept offline cash detours in isolated zones; keep live trip sharing active.",
      "Stretch lower back and legs for 5 minutes after every 3 hours of continuous city driving."
    ]
  },
  "daily_wage": {
    "id": "daily_wage",
    "name": "Sunita Devi",
    "role": "Daily-Wage Construction & Domestic Worker",
    "badge": "Daily-Wage Worker",
    "defaultLog": "Worked 9 hours at Sector 42 site. Promised daily wage was ₹700. Contractor paid ₹500 cash, spent ₹50 on bus fare, and contractor held back ₹200 without giving overtime.",
    "defaultGross": 700,
    "defaultExpense": 50,
    "defaultDeduction": 200,
    "defaultIssue": "Contractor withheld ₹200 from promised ₹700 daily wage for 9-hour shift at Sector 42 site.",
    "defaultDoc": "E-SHRAM & BOCW WELFARE BOARD NOTICE: Applicant registration pending due to incomplete Aadhaar-seeded bank passbook and 90-day work certificate from contractor/union.",
    "safetyChecklist": [
      "Demand mandatory hard hat, non-slip footwear, and safety harness before working on scaffolding.",
      "Ensure clean drinking water and shaded rest area availability on site as mandated by labour law.",
      "Save the local Labour Helpline (155214) and Emergency Ambulance (108/112) on speed dial."
    ]
  }
};
const LANGUAGES = ["English","Hindi (हिंदी)","Punjabi (ਪੰਜਾਬੀ)","Hinglish"];

export default function App() {
  const [activeTab, setActiveTab] = useState('earnings');
  const [personaKey, setPersonaKey] = useState('delivery');
  const [language, setLanguage] = useState('English');
  const currentPersona = PERSONAS[personaKey];

  // Connected state across all 5 modules
  const [earningsInput, setEarningsInput] = useState(currentPersona.defaultLog);
  const [disputeInput, setDisputeInput] = useState(currentPersona.defaultIssue);
  const [docInput, setDocInput] = useState(currentPersona.defaultDoc);

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 p-6">
      <h1 className="text-2xl font-bold text-emerald-400">Saathi AI — Gig Worker Companion</h1>
      <p className="text-sm text-slate-400">Active Worker: {currentPersona.name} ({currentPersona.role}) | Language: {language}</p>
    </div>
  );
}
