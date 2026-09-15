/**
 * seed_schedules.js
 *
 * One-time script to seed the "schedules" collection in Firestore with
 * the real EDU Shuttle Bus timetable (Sunday–Thursday, effective 07-06-2026).
 *
 * SETUP:
 *   1. npm install firebase-admin
 *   2. In the Firebase Console -> Project Settings -> Service Accounts,
 *      click "Generate new private key" and save the file as
 *      serviceAccountKey.json in this same folder.
 *   3. Run:  node seed_schedules.js
 */

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

const schedules = [
  // ---------- A. TOWARDS UNIVERSITY ----------
  { time: '07:50', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Agrabad → EDU Campus', busId: 'Bus-04', busName: 'Bus-04 • Amir/Emon', status: 'onTime', period: 'morning' },
  { time: '08:50', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Boropole → Agrabad → Kajerdewry → Chawkbajar → Probartak Circle → EDU Campus', busId: 'Bus-03', busName: 'Bus-03 • Elias/Shopon (Admin & Faculty)', status: 'onTime', period: 'morning' },
  { time: '08:55', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Boropole → Agrabad → Probartak Circle → EDU Campus', busId: 'Bus-02', busName: 'Bus-02 • Saiful/Belal', status: 'onTime', period: 'morning' },
  { time: '09:00', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Chawkbajar → Probartak Circle → EDU Campus', busId: 'Bus-01', busName: 'Bus-01 • Uzzal/Jahangir', status: 'onTime', period: 'morning' },
  { time: '09:35', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Probartak Circle → 2no Gate → EDU Campus', busId: 'Bus-04', busName: 'Bus-04', status: 'onTime', period: 'morning' },
  { time: '11:15', endTime: 'To EDU Campus', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-01', busName: 'Bus-01', status: 'onTime', period: 'mid_morning' },
  { time: '11:30', endTime: 'To EDU Campus', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'mid_morning' },
  { time: '12:45', endTime: 'To EDU Campus', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-03', busName: 'Bus-03', status: 'onTime', period: 'mid_morning' },
  { time: '12:50', endTime: 'To EDU Campus', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-01', busName: 'Bus-01', status: 'onTime', period: 'mid_morning' },
  { time: '13:45', endTime: 'To EDU Campus', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'mid_morning' },
  { time: '13:50', endTime: 'To EDU Campus', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-04', busName: 'Bus-04', status: 'onTime', period: 'mid_morning' },
  { time: '16:30', endTime: 'To EDU Campus • Sun, Tue, Thu only', routeId: 'towards', routeName: '2no Gate Circle → EDU Campus', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'afternoon' },
  { time: '18:00', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Probartak Circle → 2no Gate → EDU Campus', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'evening' },
  { time: '18:10', endTime: 'To EDU Campus', routeId: 'towards', routeName: 'Probartak Circle → 2no Gate → EDU Campus', busId: 'Bus-04', busName: 'Bus-04', status: 'onTime', period: 'evening' },

  // ---------- B. FROM UNIVERSITY ----------
  { time: '12:10', endTime: 'To 2no Gate Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate Circle', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'mid_morning' },
  { time: '12:15', endTime: 'To 2no Gate Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate Circle', busId: 'Bus-04', busName: 'Bus-04', status: 'onTime', period: 'mid_morning' },
  { time: '12:20', endTime: 'To 2no Gate Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate Circle', busId: 'Bus-03', busName: 'Bus-03', status: 'onTime', period: 'mid_morning' },
  { time: '15:40', endTime: 'To 2no Gate Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate Circle', busId: 'Bus-01', busName: 'Bus-01', status: 'onTime', period: 'afternoon' },
  { time: '15:50', endTime: 'To 2no Gate Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate Circle', busId: 'Bus-04', busName: 'Bus-04 • Sumon/Nayon', status: 'onTime', period: 'afternoon' },
  { time: '16:05', endTime: 'To Probartak Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Probartak Circle', busId: 'Bus-02', busName: 'Bus-02 • Rubel/Jasim', status: 'onTime', period: 'afternoon' },
  { time: '16:40', endTime: 'To Boropole Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Probartak → Kazerdewry → Agrabad → Boropole', busId: 'Bus-03', busName: 'Bus-03 • Elias/Shopon (Admin & Faculty)', status: 'onTime', period: 'afternoon' },
  { time: '17:40', endTime: 'To Probartak Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Probartak', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'evening' },
  { time: '18:00', endTime: 'To Probartak Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Probartak', busId: 'Bus-04', busName: 'Bus-04', status: 'onTime', period: 'evening' },
  { time: '18:40', endTime: 'To Boropole Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Agrabad → Boropole', busId: 'Bus-01', busName: 'Bus-01', status: 'onTime', period: 'evening' },
  { time: '21:35', endTime: 'To Probartak Circle', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Probartak Circle', busId: 'Bus-01', busName: 'Bus-01', status: 'onTime', period: 'evening' },
  { time: '21:35', endTime: 'To Agrabad', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Probartak Circle → Agrabad', busId: 'Bus-04', busName: 'Bus-04', status: 'onTime', period: 'evening' },
  { time: '21:35', endTime: 'To Agrabad (MBA Program)', routeId: 'from', routeName: 'EDU Campus → 2no Gate → Agrabad', busId: 'Bus-02', busName: 'Bus-02', status: 'onTime', period: 'evening' },

  // ---------- Laguna Service (continuous, EDU <-> Polytechnical Circle) ----------
  { time: '07:00', endTime: 'EDU ↔ Polytechnical Circle • A-Shift (07:00AM–03:00PM)', routeId: 'laguna', routeName: 'Laguna Service — Shift A', busId: 'Laguna', busName: 'Driver: Yasin • Helper: Jahangir', status: 'onTime', period: 'laguna' },
  { time: '15:00', endTime: 'EDU ↔ Polytechnical Circle • B-Shift (03:00PM–11:00PM)', routeId: 'laguna', routeName: 'Laguna Service — Shift B', busId: 'Laguna', busName: 'Driver: Bipul • Helper: Shopon', status: 'onTime', period: 'laguna' },
];

async function seed() {
  const collection = db.collection('schedules');
  const batch = db.batch();

  schedules.forEach((s) => {
    const docRef = collection.doc();
    batch.set(docRef, s);
  });

  await batch.commit();
  console.log(`Seeded ${schedules.length} schedule documents into "schedules".`);
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seeding failed:', err);
    process.exit(1);
  });