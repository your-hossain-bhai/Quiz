(function () {
  'use strict';

  // ============== STORAGE ==============
  const STORAGE = {
    user: 'qh.user',
    leaderboard: 'qh.leaderboard',
    history: 'qh.history',
    plan: 'qh.plan'
  };

  function load(key, fallback) {
    try {
      const raw = localStorage.getItem(key);
      return raw ? JSON.parse(raw) : fallback;
    } catch (e) {
      return fallback;
    }
  }
  function save(key, value) {
    try { localStorage.setItem(key, JSON.stringify(value)); } catch (e) {}
  }

  // ============== TOAST ==============
  const toastEl = document.getElementById('toast');
  let toastTimer = null;
  function toast(msg) {
    if (!toastEl) return;
    toastEl.textContent = msg;
    toastEl.classList.remove('hidden');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toastEl.classList.add('hidden'), 2400);
  }

  // ============== DATA ==============
  const CATEGORIES = [
    { id: 'general', name: 'General Knowledge', emoji: '🧠', count: 5 },
    { id: 'science', name: 'Science', emoji: '🔬', count: 5 },
    { id: 'history', name: 'History', emoji: '🏛️', count: 5 },
    { id: 'geography', name: 'Geography', emoji: '🌍', count: 5 },
    { id: 'sports', name: 'Sports', emoji: '⚽', count: 5 },
    { id: 'tech', name: 'Technology', emoji: '💻', count: 5 }
  ];

  const QUESTIONS = {
    general: [
      { q: 'What is the largest ocean on Earth?', o: ['Atlantic', 'Indian', 'Pacific', 'Arctic'], a: 2 },
      { q: 'How many continents are there?', o: ['5', '6', '7', '8'], a: 2 },
      { q: 'Which planet is known as the Red Planet?', o: ['Venus', 'Mars', 'Jupiter', 'Saturn'], a: 1 },
      { q: 'What is the capital of Australia?', o: ['Sydney', 'Melbourne', 'Canberra', 'Perth'], a: 2 },
      { q: 'Which language has the most native speakers worldwide?', o: ['English', 'Spanish', 'Mandarin Chinese', 'Hindi'], a: 2 }
    ],
    science: [
      { q: 'What is the chemical symbol for gold?', o: ['Gd', 'Go', 'Au', 'Ag'], a: 2 },
      { q: 'Which gas do plants absorb from the atmosphere?', o: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'], a: 2 },
      { q: 'What is the speed of light (approx)?', o: ['300,000 km/s', '150,000 km/s', '1,000 km/s', '3,000 km/s'], a: 0 },
      { q: 'How many bones are in the adult human body?', o: ['186', '206', '226', '256'], a: 1 },
      { q: 'What is the hardest natural substance?', o: ['Quartz', 'Diamond', 'Steel', 'Titanium'], a: 1 }
    ],
    history: [
      { q: 'In which year did World War II end?', o: ['1943', '1944', '1945', '1946'], a: 2 },
      { q: 'Who was the first president of the United States?', o: ['Thomas Jefferson', 'George Washington', 'John Adams', 'Abraham Lincoln'], a: 1 },
      { q: 'The Great Wall of China was mainly built to defend against which group?', o: ['Mongols', 'Romans', 'Vikings', 'Persians'], a: 0 },
      { q: 'Which civilization built the pyramids of Giza?', o: ['Romans', 'Greeks', 'Egyptians', 'Mayans'], a: 2 },
      { q: 'When did the Berlin Wall fall?', o: ['1987', '1989', '1991', '1993'], a: 1 }
    ],
    geography: [
      { q: 'Which is the longest river in the world?', o: ['Amazon', 'Nile', 'Yangtze', 'Mississippi'], a: 1 },
      { q: 'Mount Everest lies on the border of which two countries?', o: ['India & China', 'Nepal & China', 'Nepal & India', 'Pakistan & China'], a: 1 },
      { q: 'Which desert is the largest hot desert?', o: ['Gobi', 'Sahara', 'Kalahari', 'Arabian'], a: 1 },
      { q: 'What is the capital of Canada?', o: ['Toronto', 'Vancouver', 'Ottawa', 'Montreal'], a: 2 },
      { q: 'Which country has the most natural lakes?', o: ['USA', 'Russia', 'Canada', 'Finland'], a: 2 }
    ],
    sports: [
      { q: 'How many players are on a standard soccer team on the field?', o: ['9', '10', '11', '12'], a: 2 },
      { q: 'In which sport is the term "slam dunk" used?', o: ['Tennis', 'Cricket', 'Basketball', 'Baseball'], a: 2 },
      { q: 'The Olympics are held every how many years?', o: ['2', '3', '4', '5'], a: 2 },
      { q: 'Which country has won the most FIFA World Cups?', o: ['Germany', 'Argentina', 'Brazil', 'Italy'], a: 2 },
      { q: 'In tennis, a score of zero is called?', o: ['Nil', 'Zero', 'Love', 'Duck'], a: 2 }
    ],
    tech: [
      { q: 'Who is the co-founder of Microsoft?', o: ['Steve Jobs', 'Bill Gates', 'Larry Page', 'Elon Musk'], a: 1 },
      { q: 'What does HTTP stand for?', o: ['HyperText Transfer Protocol', 'High Transfer Text Protocol', 'HyperText Transport Process', 'Home Tool Text Protocol'], a: 0 },
      { q: 'Which company developed the iPhone?', o: ['Samsung', 'Apple', 'Google', 'Microsoft'], a: 1 },
      { q: 'What year was the first iPhone released?', o: ['2005', '2007', '2009', '2010'], a: 1 },
      { q: 'What does "AI" stand for?', o: ['Automated Input', 'Artificial Intelligence', 'Algorithmic Interface', 'Applied Integration'], a: 1 }
    ]
  };

  const SEED_LEADERS = [
    { name: 'Aarav S.', score: 980, takenAt: Date.now() - 86400000 },
    { name: 'Maya R.', score: 940, takenAt: Date.now() - 3600000 },
    { name: 'Leo K.', score: 920, takenAt: Date.now() - 7200000 },
    { name: 'Sofia P.', score: 890, takenAt: Date.now() - 1800000 },
    { name: 'Idris A.', score: 870, takenAt: Date.now() - 5400000 },
    { name: 'Hana T.', score: 840, takenAt: Date.now() - 9000000 },
    { name: 'Noah B.', score: 810, takenAt: Date.now() - 6300000 },
    { name: 'Zara M.', score: 780, takenAt: Date.now() - 2700000 },
    { name: 'Kai L.', score: 740, takenAt: Date.now() - 14400000 },
    { name: 'Riya D.', score: 700, takenAt: Date.now() - 10800000 }
  ];

  const FEATURE_INFO = {
    quiz: {
      icon: '📚',
      title: 'Category-Based Quizzes',
      desc: 'Hundreds of curated questions across 6 categories — from General Knowledge to Tech. Every quiz gives you instant feedback so you learn as you play.',
      bullets: ['6 categories, 30+ questions', 'Instant feedback after each answer', 'Track progress over time', 'Difficulty scales with you'],
      tab: 'quiz'
    },
    leaderboard: {
      icon: '🏆',
      title: 'Live Leaderboard',
      desc: 'See how you stack up against the community. Filter by All Time, This Week, or Today. Your latest scores appear automatically.',
      bullets: ['Real-time rankings', 'Daily / weekly / all-time filters', 'Personal best tracking', 'Shareable results'],
      tab: 'leaderboard'
    },
    results: {
      icon: '📊',
      title: 'Instant Results',
      desc: 'No waiting — the moment you finish a quiz, get a clean breakdown of your score, accuracy, and where to improve.',
      bullets: ['Score and accuracy at a glance', 'Time-per-question stats', 'Topic-wise breakdown', 'Suggested next quiz'],
      tab: 'quiz'
    },
    profile: {
      icon: '👤',
      title: 'User Profile',
      desc: 'Your stats, saved quizzes, and streak — all in one place. Edit your avatar and name to make it yours.',
      bullets: ['Quizzes taken counter', 'Average accuracy tracking', 'Day streak counter', 'Edit name and avatar'],
      tab: 'profile'
    },
    ai: {
      icon: '🤖',
      title: 'AI Tutor',
      desc: 'Stuck on a concept? Ask anything. The AI tutor explains topics, gives hints, and tailors responses to your level.',
      bullets: ['24/7 instant answers', 'Context-aware hints', 'Plain-language explanations', 'Topic deep-dives'],
      tab: 'ai'
    },
    subscription: {
      icon: '⭐',
      title: 'Premium Plans',
      desc: 'Unlock unlimited quizzes, advanced analytics, and an ad-free experience with Pro or Team plans.',
      bullets: ['Unlimited daily quizzes', 'Advanced analytics', 'No ads, ever', 'Team leaderboards'],
      tab: 'subscription'
    }
  };

  // ============== STATE ==============
  let state = {
    user: load(STORAGE.user, null),
    leaderboard: load(STORAGE.leaderboard, SEED_LEADERS),
    history: load(STORAGE.history, []),
    plan: load(STORAGE.plan, 'free'),
    quiz: null
  };

  // Seed leaderboard only first time
  if (!load(STORAGE.leaderboard, null)) {
    save(STORAGE.leaderboard, SEED_LEADERS);
  }

  // ============== INIT ==============
  document.addEventListener('DOMContentLoaded', () => {
    setupNav();
    setupScrollAnimations();
    setupHeroParallax();
    setupFeatures();
    setupDemoTabs();
    setupQuiz();
    setupLeaderboard();
    setupProfile();
    setupAI();
    setupSubscription();
    setupAuth();
    setupModals();
    applyUser();
    renderLeaderboard();
    renderProfile();
  });

  // ============== NAV & SMOOTH SCROLL ==============
  function setupNav() {
    document.getElementById('exploreBtn')?.addEventListener('click', () => {
      document.getElementById('features').scrollIntoView({ behavior: 'smooth' });
    });
    document.getElementById('getStartedBtn')?.addEventListener('click', () => {
      openAuth('signup');
    });
    document.getElementById('ctaSignupBtn')?.addEventListener('click', () => {
      openAuth('signup');
    });
    document.getElementById('loginNavBtn')?.addEventListener('click', () => openAuth('login'));
    document.getElementById('signupNavBtn')?.addEventListener('click', () => openAuth('signup'));
  }

  function setupScrollAnimations() {
    const selector = '.card[data-animate], .feature, .tech-card';
    const elements = Array.from(document.querySelectorAll(selector));
    if ('IntersectionObserver' in window) {
      try {
        const observer = new IntersectionObserver((entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add('in-view');
              observer.unobserve(entry.target);
            }
          });
        }, { threshold: 0.12 });
        elements.forEach((el) => observer.observe(el));
      } catch (e) {
        elements.forEach((el) => el.classList.add('in-view'));
      }
    } else {
      setTimeout(() => elements.forEach((el) => el.classList.add('in-view')), 200);
    }
  }

  function setupHeroParallax() {
    const heroCard = document.querySelector('.hero-card');
    const heroSection = document.querySelector('.hero');
    if (heroSection && heroCard) {
      heroSection.addEventListener('mousemove', (e) => {
        const rect = heroSection.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width - 0.5;
        const y = (e.clientY - rect.top) / rect.height - 0.5;
        heroCard.style.transform = `translate3d(${x * 8}px, ${y * 8}px, 0)`;
      });
      heroSection.addEventListener('mouseleave', () => {
        heroCard.style.transform = '';
      });
    }
  }

  // ============== FEATURE CARDS ==============
  function setupFeatures() {
    document.querySelectorAll('.feature').forEach((card) => {
      card.addEventListener('click', () => {
        const key = card.getAttribute('data-feature');
        if (key && FEATURE_INFO[key]) openFeatureModal(key);
      });
    });
  }

  // ============== DEMO TABS ==============
  function setupDemoTabs() {
    document.querySelectorAll('.demo-tab').forEach((tab) => {
      tab.addEventListener('click', () => {
        const target = tab.getAttribute('data-tab');
        document.querySelectorAll('.demo-tab').forEach((t) => t.classList.remove('active'));
        document.querySelectorAll('.demo-panel').forEach((p) => p.classList.remove('active'));
        tab.classList.add('active');
        const panel = document.getElementById('panel-' + target);
        if (panel) panel.classList.add('active');
      });
    });

    // Hero "Try Demo" button
    document.querySelectorAll('[data-open-demo]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const target = btn.getAttribute('data-open-demo');
        const tab = document.querySelector('.demo-tab[data-tab="' + target + '"]');
        if (tab) tab.click();
        document.getElementById('demo')?.scrollIntoView({ behavior: 'smooth' });
      });
    });
  }

  // ============== QUIZ ==============
  function setupQuiz() {
    const catGrid = document.getElementById('catGrid');
    if (catGrid) {
      catGrid.innerHTML = '';
      CATEGORIES.forEach((cat) => {
        const btn = document.createElement('button');
        btn.className = 'cat-card';
        btn.innerHTML = `
          <div class="emoji">${cat.emoji}</div>
          <div class="name">${cat.name}</div>
          <div class="meta">${cat.count} questions</div>
        `;
        btn.addEventListener('click', () => startQuiz(cat.id));
        catGrid.appendChild(btn);
      });
    }

    document.getElementById('qQuitBtn')?.addEventListener('click', quitQuiz);
    document.getElementById('qNextBtn')?.addEventListener('click', nextQuestion);
    document.getElementById('resultAgainBtn')?.addEventListener('click', () => {
      showStage('start');
    });
    document.getElementById('resultShareBtn')?.addEventListener('click', () => {
      const score = state.quiz ? state.quiz.score : 0;
      const total = state.quiz ? state.quiz.questions.length : 0;
      const text = `I scored ${score}/${total} on ${state.quiz?.categoryName || 'QuizHub'}! 🚀`;
      if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(
          () => toast('Result copied to clipboard'),
          () => toast(text)
        );
      } else {
        toast(text);
      }
    });
  }

  function showStage(stage) {
    document.getElementById('quizStart')?.classList.toggle('hidden', stage !== 'start');
    document.getElementById('quizPlay')?.classList.toggle('hidden', stage !== 'play');
    document.getElementById('quizResult')?.classList.toggle('hidden', stage !== 'result');
  }

  function startQuiz(catId) {
    const cat = CATEGORIES.find((c) => c.id === catId);
    const list = QUESTIONS[catId] || [];
    if (!cat || list.length === 0) {
      toast('No questions available.');
      return;
    }
    state.quiz = {
      categoryId: catId,
      categoryName: cat.name,
      questions: list,
      index: 0,
      score: 0,
      answers: []
    };
    showStage('play');
    renderQuestion();
  }

  function renderQuestion() {
    if (!state.quiz) return;
    const { index, questions, categoryName } = state.quiz;
    const q = questions[index];
    document.getElementById('qCategory').textContent = categoryName;
    document.getElementById('qProgress').textContent = `Question ${index + 1}/${questions.length}`;
    document.getElementById('qText').textContent = q.q;
    document.getElementById('quizBarFill').style.width = `${((index) / questions.length) * 100}%`;

    const optWrap = document.getElementById('qOptions');
    optWrap.innerHTML = '';
    q.o.forEach((text, i) => {
      const btn = document.createElement('button');
      btn.className = 'q-opt';
      btn.type = 'button';
      btn.textContent = text;
      btn.addEventListener('click', () => answerQuestion(i, btn));
      optWrap.appendChild(btn);
    });

    const fb = document.getElementById('qFeedback');
    fb.classList.add('hidden');
    fb.textContent = '';
    const nextBtn = document.getElementById('qNextBtn');
    nextBtn.classList.add('hidden');
  }

  function answerQuestion(picked, btn) {
    if (!state.quiz) return;
    const { index, questions } = state.quiz;
    const q = questions[index];
    const correct = picked === q.a;
    state.quiz.answers.push({ picked, correct });

    const opts = document.querySelectorAll('#qOptions .q-opt');
    opts.forEach((o, i) => {
      o.disabled = true;
      if (i === q.a) o.classList.add('correct');
      if (i === picked && !correct) o.classList.add('wrong');
    });

    if (correct) state.quiz.score++;

    const fb = document.getElementById('qFeedback');
    fb.classList.remove('hidden', 'correct', 'wrong');
    fb.classList.add(correct ? 'correct' : 'wrong');
    fb.textContent = correct
      ? `✓ Correct! ${q.o[q.a]}`
      : `✗ Not quite. The correct answer is "${q.o[q.a]}".`;

    const nextBtn = document.getElementById('qNextBtn');
    nextBtn.classList.remove('hidden');
    nextBtn.textContent = index === questions.length - 1 ? 'See Results' : 'Next';
  }

  function nextQuestion() {
    if (!state.quiz) return;
    state.quiz.index++;
    if (state.quiz.index >= state.quiz.questions.length) {
      finishQuiz();
    } else {
      renderQuestion();
    }
  }

  function quitQuiz() {
    state.quiz = null;
    showStage('start');
    toast('Quiz cancelled.');
  }

  function finishQuiz() {
    if (!state.quiz) return;
    const { score, questions, categoryName } = state.quiz;
    document.getElementById('quizBarFill').style.width = '100%';

    const total = questions.length;
    const pct = Math.round((score / total) * 100);

    document.getElementById('resultTitle').textContent = pct >= 80 ? 'Outstanding!' : pct >= 50 ? 'Good effort!' : 'Keep practicing!';
    document.getElementById('resultScore').textContent = `${score}/${total}`;
    document.getElementById('resultSummary').textContent =
      `You scored ${pct}% on ${categoryName}. ${pct >= 80 ? 'You crushed it.' : pct >= 50 ? 'Solid run.' : 'Try again to improve.'}`;

    // Record history + leaderboard
    const displayName = state.user ? state.user.name : 'Guest';
    const entry = {
      name: displayName,
      score: score * 100,
      takenAt: Date.now(),
      category: categoryName,
      correct: score,
      total
    };
    state.history.unshift(entry);
    save(STORAGE.history, state.history.slice(0, 50));

    if (state.user) {
      state.leaderboard.unshift({
        name: state.user.name,
        score: score * 100,
        takenAt: Date.now()
      });
      state.leaderboard.sort((a, b) => b.score - a.score);
      state.leaderboard = state.leaderboard.slice(0, 50);
      save(STORAGE.leaderboard, state.leaderboard);
    }

    showStage('result');
    renderLeaderboard();
    renderProfile();
    toast(`Saved: ${score}/${total} on ${categoryName}`);
  }

  // ============== LEADERBOARD ==============
  function setupLeaderboard() {
    document.querySelectorAll('[data-lb-filter]').forEach((chip) => {
      chip.addEventListener('click', () => {
        document.querySelectorAll('[data-lb-filter]').forEach((c) => c.classList.remove('active'));
        chip.classList.add('active');
        renderLeaderboard();
      });
    });
  }

  function renderLeaderboard() {
    const list = document.getElementById('lbList');
    if (!list) return;
    const filter = document.querySelector('[data-lb-filter].active')?.getAttribute('data-lb-filter') || 'all';
    const now = Date.now();
    let data = (state.leaderboard || []).slice();
    if (filter === 'today') {
      data = data.filter((e) => now - e.takenAt < 86400000);
    } else if (filter === 'week') {
      data = data.filter((e) => now - e.takenAt < 7 * 86400000);
    }
    data.sort((a, b) => b.score - a.score);
    data = data.slice(0, 10);

    if (data.length === 0) {
      list.innerHTML = '<li class="lb-row"><div class="lb-rank">·</div><div class="lb-name">No entries yet — take a quiz!</div><div class="lb-score"></div></li>';
      return;
    }

    list.innerHTML = data.map((e, i) => {
      const isMe = state.user && e.name === state.user.name;
      const safe = (e.name || 'Anonymous').replace(/[<>]/g, '');
      return `
        <li class="lb-row${isMe ? ' me' : ''}">
          <div class="lb-rank">${i + 1}</div>
          <div class="lb-name">${safe}${isMe ? ' (you)' : ''}</div>
          <div class="lb-score">${e.score}</div>
        </li>
      `;
    }).join('');
  }

  // ============== PROFILE ==============
  function setupProfile() {
    document.getElementById('profileEditBtn')?.addEventListener('click', () => {
      if (!state.user) {
        openAuth('signup');
        return;
      }
      openProfileEdit();
    });
    document.getElementById('profileResetBtn')?.addEventListener('click', () => {
      if (!confirm('Reset all progress? This cannot be undone.')) return;
      state.history = [];
      save(STORAGE.history, []);
      renderProfile();
      renderLeaderboard();
      toast('Progress reset.');
    });

    const editForm = document.getElementById('profileEditForm');
    if (editForm) {
      editForm.addEventListener('submit', (e) => {
        e.preventDefault();
        if (!state.user) return;
        const fd = new FormData(editForm);
        const name = (fd.get('name') || '').toString().trim();
        const avatar = (fd.get('avatar') || '').toString().trim() || '🙂';
        if (name.length < 2) {
          toast('Name too short.');
          return;
        }
        state.user.name = name;
        state.user.avatar = avatar;
        save(STORAGE.user, state.user);
        applyUser();
        renderProfile();
        closeModal('profileEditModal');
        toast('Profile updated.');
      });
    }
  }

  function openProfileEdit() {
    if (!state.user) return;
    const form = document.getElementById('profileEditForm');
    if (!form) return;
    form.elements['name'].value = state.user.name || '';
    form.elements['avatar'].value = state.user.avatar || '🙂';
    openModal('profileEditModal');
  }

  function renderProfile() {
    const nameEl = document.getElementById('profileName');
    const emailEl = document.getElementById('profileEmail');
    const avatarEl = document.getElementById('profileAvatar');
    if (state.user) {
      nameEl.textContent = state.user.name;
      emailEl.textContent = state.user.email || 'Stats sync with your account.';
      avatarEl.textContent = state.user.avatar || '🙂';
    } else {
      nameEl.textContent = 'Guest Learner';
      emailEl.textContent = 'Sign in to sync your stats across devices.';
      avatarEl.textContent = '👤';
    }

    const hist = state.history || [];
    const totalQuizzes = hist.length;
    const totalCorrect = hist.reduce((sum, h) => sum + (h.correct || 0), 0);
    const totalQuestions = hist.reduce((sum, h) => sum + (h.total || 0), 0);
    const accuracy = totalQuestions > 0 ? Math.round((totalCorrect / totalQuestions) * 100) : 0;
    const best = hist.reduce((m, h) => Math.max(m, (h.correct || 0) * 100), 0);
    const streak = computeStreak(hist);

    document.getElementById('pstatQuizzes').textContent = totalQuizzes;
    document.getElementById('pstatAcc').textContent = accuracy + '%';
    document.getElementById('pstatBest').textContent = best;
    document.getElementById('pstatStreak').textContent = streak;
  }

  function computeStreak(history) {
    if (!history.length) return 0;
    const days = new Set(
      history.map((h) => {
        const d = new Date(h.takenAt);
        return d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
      })
    );
    let streak = 0;
    const today = new Date();
    for (let i = 0; i < 365; i++) {
      const d = new Date(today);
      d.setDate(today.getDate() - i);
      const key = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
      if (days.has(key)) streak++;
      else if (i > 0) break;
    }
    return streak;
  }

  // ============== AI CHAT ==============
  function setupAI() {
    const form = document.getElementById('aiForm');
    if (!form) return;
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const input = document.getElementById('aiInput');
      const text = (input.value || '').trim();
      if (!text) return;
      pushAIMessage('user', text);
      input.value = '';
      setTimeout(() => pushAIMessage('bot', generateAIReply(text)), 400 + Math.random() * 600);
    });
  }

  function pushAIMessage(role, text) {
    const log = document.getElementById('aiLog');
    if (!log) return;
    const wrapper = document.createElement('div');
    wrapper.className = 'ai-msg ' + role;
    const bubble = document.createElement('div');
    bubble.className = 'ai-bubble';
    bubble.innerHTML = text;
    wrapper.appendChild(bubble);
    log.appendChild(wrapper);
    log.scrollTop = log.scrollHeight;
  }

  function generateAIReply(input) {
    const msg = input.toLowerCase().trim();
    if (state.quiz && (msg === 'hint' || msg === 'help')) {
      const idx = state.quiz.index;
      const q = state.quiz.questions[idx];
      const correct = q.o[q.a];
      const letters = ['A', 'B', 'C', 'D'];
      return `Hint: The correct answer starts with "<strong>${correct.charAt(0).toUpperCase()}</strong>" (option <strong>${letters[q.a]}</strong>).`;
    }
    if (msg.includes('hello') || msg.includes('hi') || msg.includes('hey')) {
      return 'Hey there! 👋 Want a quiz recommendation, or do you have a topic you want to learn about?';
    }
    if (msg.includes('space') || msg.includes('planet')) {
      return 'Space is huge! Our solar system has 8 planets — Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune. Want to take the Science quiz?';
    }
    if (msg.includes('history') || msg.includes('war')) {
      return 'History is full of turning points. From the fall of the Berlin Wall (1989) to the Moon landing (1969), our History category has 5 questions to test you.';
    }
    if (msg.includes('math') || msg.includes('+') || msg.includes('=')) {
      return 'I can help with math! Try asking something specific like "What is 12 × 8?" or "Explain the Pythagorean theorem".';
    }
    if (msg.includes('joke')) {
      const jokes = [
        'Why did the developer go broke? Because they used up all their cache. 💸',
        'Why was the function sad? It didn\'t get called. 📞',
        'Why do programmers prefer dark mode? Because light attracts bugs. 🐛'
      ];
      return jokes[Math.floor(Math.random() * jokes.length)];
    }
    if (msg.includes('explain') || msg.includes('what is') || msg.includes('how does')) {
      return 'Great question! Here\'s a quick take: most concepts become clear with a concrete example. Try the matching quiz category for hands-on practice — and ask me to clarify any part.';
    }
    if (msg.includes('thanks') || msg.includes('thank')) {
      return 'You\'re welcome! 💪 Keep going — every question you answer makes the leaderboard.';
    }
    if (msg.includes('plan') || msg.includes('price') || msg.includes('subscription')) {
      return 'QuizHub has 3 plans: Free, Pro ($4.99/mo), and Team ($12/mo). Pro unlocks unlimited quizzes and advanced analytics. Switch to the Plans tab to see them!';
    }
    return 'Got it! I can help with quiz topics, give hints during a quiz, or explain concepts. Try asking "explain photosynthesis" or "tell me a joke".';
  }

  // ============== SUBSCRIPTION ==============
  function setupSubscription() {
    document.querySelectorAll('.sub-btn').forEach((btn) => {
      btn.addEventListener('click', () => {
        const plan = btn.getAttribute('data-plan');
        selectPlan(plan);
      });
    });
    renderPlan();
  }

  function selectPlan(plan) {
    state.plan = plan;
    save(STORAGE.plan, plan);
    renderPlan();
    const labels = { free: 'Free plan active', pro: 'Upgraded to Pro! ⭐', team: 'Team plan selected 👥' };
    toast(labels[plan] || 'Plan updated');
  }

  function renderPlan() {
    document.querySelectorAll('.sub-btn').forEach((btn) => {
      const plan = btn.getAttribute('data-plan');
      if (plan === state.plan) {
        btn.textContent = plan === 'free' ? 'Current' : plan === 'pro' ? 'Active ✓' : 'Active ✓';
        btn.disabled = true;
        btn.closest('.sub-card').classList.add('active');
      } else {
        btn.textContent = plan === 'free' ? 'Downgrade' : plan === 'pro' ? 'Upgrade' : 'Choose';
        btn.disabled = false;
        btn.closest('.sub-card').classList.remove('active');
      }
    });
  }

  // ============== AUTH ==============
  function setupAuth() {
    document.querySelectorAll('[data-auth-tab]').forEach((tab) => {
      tab.addEventListener('click', () => {
        const target = tab.getAttribute('data-auth-tab');
        document.querySelectorAll('[data-auth-tab]').forEach((t) => t.classList.remove('active'));
        document.querySelectorAll('[data-auth-form]').forEach((f) => f.classList.remove('active'));
        tab.classList.add('active');
        document.querySelector('[data-auth-form="' + target + '"]')?.classList.add('active');
      });
    });

    document.getElementById('loginForm')?.addEventListener('submit', (e) => {
      e.preventDefault();
      const fd = new FormData(e.target);
      const email = (fd.get('email') || '').toString().trim();
      const password = (fd.get('password') || '').toString();
      const msg = document.getElementById('loginMsg');
      if (!email || !password) {
        msg.textContent = 'Please fill in all fields.';
        msg.className = 'auth-msg error';
        return;
      }
      const existing = load(STORAGE.user, null);
      if (existing && existing.email === email) {
        state.user = existing;
        save(STORAGE.user, existing);
        msg.textContent = `Welcome back, ${existing.name}!`;
        msg.className = 'auth-msg success';
        setTimeout(() => finishAuth(), 600);
      } else {
        msg.textContent = 'No account found with that email. Try signing up.';
        msg.className = 'auth-msg error';
      }
    });

    document.getElementById('signupForm')?.addEventListener('submit', (e) => {
      e.preventDefault();
      const fd = new FormData(e.target);
      const name = (fd.get('name') || '').toString().trim();
      const email = (fd.get('email') || '').toString().trim();
      const password = (fd.get('password') || '').toString();
      const msg = document.getElementById('signupMsg');
      if (name.length < 2) {
        msg.textContent = 'Name must be at least 2 characters.';
        msg.className = 'auth-msg error';
        return;
      }
      if (password.length < 6) {
        msg.textContent = 'Password must be at least 6 characters.';
        msg.className = 'auth-msg error';
        return;
      }
      const user = {
        name,
        email,
        avatar: name.charAt(0).toUpperCase(),
        joinedAt: Date.now()
      };
      state.user = user;
      save(STORAGE.user, user);
      msg.textContent = `Welcome, ${name}!`;
      msg.className = 'auth-msg success';
      setTimeout(() => finishAuth(), 600);
    });
  }

  function openAuth(tab) {
    const t = tab || 'login';
    const tabBtn = document.querySelector('[data-auth-tab="' + t + '"]');
    if (tabBtn) tabBtn.click();
    openModal('authModal');
  }

  function finishAuth() {
    applyUser();
    closeModal('authModal');
    renderProfile();
    renderLeaderboard();
    toast(`Logged in as ${state.user.name}`);
  }

  function applyUser() {
    const loginBtn = document.getElementById('loginNavBtn');
    const signupBtn = document.getElementById('signupNavBtn');
    if (state.user) {
      if (loginBtn) loginBtn.textContent = state.user.name;
      if (signupBtn) {
        signupBtn.textContent = 'Log out';
        signupBtn.onclick = () => {
          state.user = null;
          localStorage.removeItem(STORAGE.user);
          applyUser();
          renderProfile();
          renderLeaderboard();
          toast('Logged out.');
        };
      }
    } else {
      if (loginBtn) {
        loginBtn.textContent = 'Log in';
        loginBtn.onclick = null;
      }
      if (signupBtn) {
        signupBtn.textContent = 'Sign up';
        signupBtn.onclick = null;
      }
    }
  }

  // ============== MODALS ==============
  function setupModals() {
    document.querySelectorAll('[data-close-modal]').forEach((el) => {
      el.addEventListener('click', () => closeModal('featureModal'));
    });
    document.querySelectorAll('[data-close-auth]').forEach((el) => {
      el.addEventListener('click', () => closeModal('authModal'));
    });
    document.querySelectorAll('[data-close-profile]').forEach((el) => {
      el.addEventListener('click', () => closeModal('profileEditModal'));
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        document.querySelectorAll('.modal').forEach((m) => m.classList.add('hidden'));
      }
    });
  }

  function openModal(id) {
    const m = document.getElementById(id);
    if (m) m.classList.remove('hidden');
  }

  function closeModal(id) {
    const m = document.getElementById(id);
    if (m) m.classList.add('hidden');
  }

  function openFeatureModal(key) {
    const info = FEATURE_INFO[key];
    if (!info) return;
    document.getElementById('featureIcon').textContent = info.icon;
    document.getElementById('featureTitle').textContent = info.title;
    document.getElementById('featureDesc').textContent = info.desc;
    const list = document.getElementById('featureBullets');
    list.innerHTML = info.bullets.map((b) => `<li>${b}</li>`).join('');
    const tryBtn = document.getElementById('featureTryBtn');
    tryBtn.onclick = () => {
      closeModal('featureModal');
      const tab = document.querySelector('.demo-tab[data-tab="' + info.tab + '"]');
      if (tab) tab.click();
      document.getElementById('demo')?.scrollIntoView({ behavior: 'smooth' });
    };
    openModal('featureModal');
  }

  // ============== EXPOSE FOR TESTING ==============
  window.QuizHub = {
    state,
    storage: STORAGE,
    openAuth,
    openFeatureModal,
    startQuiz,
    renderLeaderboard,
    renderProfile,
    selectPlan,
    pushAIMessage,
    generateAIReply,
    QUESTIONS,
    CATEGORIES
  };
})();
