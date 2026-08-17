part of '../main.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppUser? user;
  String token = '';
  late ApiClient api = ApiClient(token: token);
  bool loading = true;
  bool busy = false;
  bool syncing = false;
  bool slowConnection = false;
  String? connectionProblem;
  String message = 'Ready';
  int tab = 0;
  String weekView = 'unpaid';
  bool paymentOpen = true;
  bool signup = false;
  bool showPassword = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rateController = TextEditingController();
  WeekRecord week = createWeek();
  List<WeekRecord> weeks = [];
  ActiveTimer? activeTimer;
  DateTime now = DateTime.now();
  Timer? ticker;
  Timer? requestTimer;

  @override
  void initState() {
    super.initState();
    restore();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    requestTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rateController.dispose();
    super.dispose();
  }

  void setToken(String value) {
    token = value;
    api = ApiClient(token: token);
  }

  void beginRequest(String label, {bool block = false}) {
    requestTimer?.cancel();
    setState(() {
      syncing = true;
      slowConnection = false;
      connectionProblem = null;
      if (block) busy = true;
      message = label;
    });
    requestTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !syncing) return;
      setState(() {
        slowConnection = true;
        message = 'Still working. Connection is slow...';
      });
    });
  }

  void finishRequest(String successMessage, {bool block = false}) {
    requestTimer?.cancel();
    if (!mounted) return;
    setState(() {
      syncing = false;
      slowConnection = false;
      if (block) busy = false;
      message = successMessage;
    });
  }

  void failRequest(Object error, {bool block = false}) {
    requestTimer?.cancel();
    if (!mounted) return;
    final text = error.toString();
    setState(() {
      syncing = false;
      slowConnection = false;
      connectionProblem = text;
      if (block) busy = false;
      message = text;
    });
  }

  Future<void> fetchAll() async {
    final settings = Map<String, dynamic>.from(
      await api.getJson('/api/settings'),
    );
    final loadedWeeks = (await api.getJson('/api/weeks') as List)
        .map((item) => WeekRecord.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final current = WeekRecord.fromJson(
      Map<String, dynamic>.from(
        await api.getJson('/api/weeks/${mondayOf(DateTime.now())}'),
      ),
    );
    setState(() {
      weeks = loadedWeeks;
      week = current;
      rateController.text = settings['hourlyRate']?.toString() ?? '';
      activeTimer = settings['activeTimer'] == null
          ? null
          : ActiveTimer.fromJson(
              Map<String, dynamic>.from(settings['activeTimer']),
            );
    });
  }

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(sessionTokenKey) ?? '';
    final savedUser = prefs.getString(sessionUserKey);
    if (savedToken.isNotEmpty && savedUser != null) {
      setState(() {
        setToken(savedToken);
        user = AppUser.fromJson(jsonDecode(savedUser));
      });
      try {
        beginRequest('Restoring your workspace...');
        await fetchAll();
        finishRequest('Ready');
      } catch (error) {
        failRequest(error);
      }
    }
    setState(() => loading = false);
  }

  Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final nextUser = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
    final nextToken = data['accessToken']?.toString() ?? '';
    await prefs.setString(sessionTokenKey, nextToken);
    await prefs.setString(sessionUserKey, jsonEncode(nextUser.toJson()));
    setState(() {
      user = nextUser;
      setToken(nextToken);
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionTokenKey);
    await prefs.remove(sessionUserKey);
    setState(() {
      user = null;
      setToken('');
      weeks = [];
      week = createWeek();
      activeTimer = null;
      rateController.clear();
      tab = 0;
    });
  }

  Future<void> submitAuth() async {
    if (busy) return;
    beginRequest(signup ? 'Creating account...' : 'Signing in...', block: true);
    try {
      final data =
          await api.postJson(signup ? '/api/auth/signup' : '/api/auth/login', {
        if (signup) 'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });
      await saveSession(Map<String, dynamic>.from(data));
      await fetchAll();
      finishRequest(signup ? 'Account created.' : 'Logged in.', block: true);
    } catch (error) {
      failRequest(error, block: true);
    }
  }

  Future<void> loadAll() async {
    beginRequest('Refreshing workspace...');
    try {
      await fetchAll();
      finishRequest('Ready');
    } catch (error) {
      failRequest(error);
    }
  }

  Future<void> saveSettings() async {
    if (rateController.text.trim().isEmpty ||
        (double.tryParse(rateController.text) ?? 0) <= 0) {
      setState(() => message = 'Enter your hourly rate.');
      return;
    }
    beginRequest('Saving hourly rate...', block: true);
    try {
      await api.putJson('/api/settings', {
        'hourlyRate': rateController.text.trim(),
      });
      finishRequest('Hourly rate saved.', block: true);
    } catch (error) {
      failRequest(error, block: true);
    }
  }

  Future<void> saveWeek(WeekRecord target) async {
    await api.putJson('/api/weeks/${target.weekStart}', target.toJson());
    await fetchAll();
  }

  Future<void> loadWeek(String weekStart) async {
    beginRequest('Loading week...');
    try {
      final loaded = WeekRecord.fromJson(
        Map<String, dynamic>.from(await api.getJson('/api/weeks/$weekStart')),
      );
      setState(() {
        week = loaded;
      });
      finishRequest('Ready');
    } catch (error) {
      failRequest(error);
    }
  }

  Future<void> navigateWeek(String direction) async {
    final current = DateTime.parse(week.weekStart);
    if (direction == 'current') {
      await loadWeek(mondayOf(DateTime.now()));
      return;
    }
    await loadWeek(
      DateFormat('yyyy-MM-dd').format(
        current.add(Duration(days: direction == 'next' ? 7 : -7)),
      ),
    );
  }

  Future<void> pickWeekStart() async {
    final current = DateTime.parse(week.weekStart);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select week date',
    );
    if (picked == null) return;
    await loadWeek(mondayOf(picked));
  }

  Future<void> showSavedWeeksPicker() async {
    if (weeks.isEmpty) {
      setState(() => message = 'No saved weeks yet.');
      return;
    }
    final sorted = [...weeks]
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
            shrinkWrap: true,
            children: [
              const Text(
                'Saved weeks',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...sorted.map((item) {
                final hours = item.days.fold<double>(
                  0,
                  (sum, day) => sum + calculateDayHours(day),
                );
                final selectedWeek = item.weekStart == week.weekStart;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => Navigator.pop(context, item.weekStart),
                    selected: selectedWeek,
                    selectedTileColor: const Color(0xffedf7f4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selectedWeek
                            ? const Color(0xff9ccac1)
                            : const Color(0xffdbe7e4),
                      ),
                    ),
                    leading: Icon(
                      item.isPaid ? Icons.check_circle : Icons.schedule,
                      color: item.isPaid
                          ? const Color(0xff1d6f68)
                          : const Color(0xffa1432f),
                    ),
                    title: Text(
                      'Week ${item.weekStart}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${hours.toStringAsFixed(2)} hours - ${money(hours * rate)}',
                    ),
                    trailing: selectedWeek
                        ? const Icon(Icons.check, color: Color(0xff1d6f68))
                        : null,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    await loadWeek(selected);
  }

  Future<void> deleteWeek() async {
    if (activeTimer != null) {
      setState(() => message = 'Stop the running shift before deleting.');
      return;
    }
    beginRequest('Deleting week...', block: true);
    try {
      await api.delete('/api/weeks/${week.weekStart}');
      await fetchAll();
      finishRequest('Week deleted.', block: true);
    } catch (error) {
      failRequest(error, block: true);
    }
  }

  Future<void> toggleTimer(int index) async {
    if (busy) return;
    final running = activeTimer?.weekStart == week.weekStart &&
        activeTimer?.dayIndex == index;
    beginRequest(running ? 'Stopping shift...' : 'Starting shift...',
        block: true);
    try {
      final copy = WeekRecord(
        weekStart: week.weekStart,
        isPaid: week.isPaid,
        days: week.days.map((day) => day.copy()).toList(),
      );
      final clock = formatClock(DateTime.now());
      if (running) {
        copy.days[index].end = clock;
        await api.delete('/api/settings/timer');
        await api.putJson('/api/weeks/${copy.weekStart}', copy.toJson());
        setState(() {
          activeTimer = null;
          week = copy;
        });
        finishRequest('Shift stopped and saved.', block: true);
      } else {
        if (activeTimer != null) {
          finishRequest('Stop the running shift first.', block: true);
          return;
        }
        copy.days[index].start = clock;
        copy.days[index].end = '';
        final timer = ActiveTimer(
          weekStart: week.weekStart,
          dayIndex: index,
          startedAt: DateTime.now(),
          startTime: clock,
        );
        await api.putJson('/api/settings/timer', timer.toJson());
        await api.putJson('/api/weeks/${copy.weekStart}', copy.toJson());
        setState(() {
          activeTimer = timer;
          week = copy;
        });
        finishRequest('Shift started.', block: true);
      }
      beginRequest('Refreshing workspace...');
      await fetchAll();
      finishRequest('Ready');
    } catch (error) {
      failRequest(error, block: true);
    }
  }

  Future<void> togglePaid(WeekRecord target) async {
    if (activeTimer != null) {
      setState(() =>
          message = 'Stop the running shift before changing payment status.');
      return;
    }
    target.isPaid = !target.isPaid;
    beginRequest(target.isPaid ? 'Marking paid...' : 'Marking unpaid...',
        block: true);
    try {
      await saveWeek(target);
      finishRequest(target.isPaid ? 'Week marked paid.' : 'Week marked unpaid.',
          block: true);
    } catch (error) {
      target.isPaid = !target.isPaid;
      failRequest(error, block: true);
    }
  }

  Future<void> clearDay(int index) async {
    if (activeTimer != null) {
      setState(() => message = 'Stop the running shift before editing.');
      return;
    }
    final copy = WeekRecord(
      weekStart: week.weekStart,
      isPaid: week.isPaid,
      days: week.days.map((day) => day.copy()).toList(),
    );
    copy.days[index]
      ..start = ''
      ..end = ''
      ..breakMinutes = 0;
    setState(() => week = copy);
    beginRequest('Clearing hours...', block: true);
    try {
      await saveWeek(copy);
      finishRequest('Hours cleared.', block: true);
    } catch (error) {
      failRequest(error, block: true);
    }
  }

  Future<void> saveNote(int index, String note) async {
    final cleanNote = note.trim();
    if (week.days[index].notes == cleanNote) return;
    final copy = WeekRecord(
      weekStart: week.weekStart,
      isPaid: week.isPaid,
      days: week.days.map((day) => day.copy()).toList(),
    );
    copy.days[index].notes = cleanNote;
    setState(() => week = copy);
    beginRequest('Saving note...');
    try {
      await saveWeek(copy);
      finishRequest('Note saved.');
    } catch (error) {
      failRequest(error);
    }
  }

  double get rate => double.tryParse(rateController.text) ?? 0;

  List<double> get dailyHours {
    return week.days.asMap().entries.map((entry) {
      final running = activeTimer?.weekStart == week.weekStart &&
          activeTimer?.dayIndex == entry.key;
      return running
          ? calculateLiveHours(entry.value, activeTimer, now)
          : calculateDayHours(entry.value);
    }).toList();
  }

  double get weeklyHours => dailyHours.fold(0, (sum, value) => sum + value);
  double get weeklyPay => weeklyHours * rate;
  int get todayIndex => DateTime.now().weekday - 1;
  int get activeIndex => activeTimer?.weekStart == week.weekStart
      ? activeTimer!.dayIndex
      : todayIndex;

  Widget requestBanner() {
    return AppStateBanner(
      syncing: syncing,
      slow: slowConnection,
      error: connectionProblem,
      message: message,
      onRetry: user == null ? null : loadAll,
      onDismiss: () => setState(() => connectionProblem = null),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingStateScreen(slow: slowConnection);
    }
    if (user == null) return authScreen();
    if (rateController.text.trim().isEmpty) return rateScreen();

    return Scaffold(
      backgroundColor: const Color(0xffedf5f3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: requestBanner(),
            ),
            Expanded(
              child: IndexedStack(
                index: tab,
                children: [workScreen(), dashboardScreen(), recordsScreen()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Work',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Records',
          ),
        ],
      ),
    );
  }

  Widget authScreen() {
    return Scaffold(
      backgroundColor: const Color(0xffedf5f3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('PUNCH IN'),
                  Text(
                    signup ? 'Create account.' : 'Welcome back.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  if (signup)
                    AppTextField(
                      controller: nameController,
                      icon: Icons.person_outline,
                      hint: 'Full name',
                    ),
                  AppTextField(
                    controller: emailController,
                    icon: Icons.mail_outline,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  AppTextField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    hint: 'Password',
                    obscureText: !showPassword,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                      icon: Icon(
                        showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: busy
                        ? (signup ? 'Signing up...' : 'Signing in...')
                        : (signup ? 'Create account' : 'Sign in'),
                    icon: Icons.check,
                    loading: busy,
                    onPressed: busy ? null : submitAuth,
                  ),
                  TextButton(
                    onPressed:
                        busy ? null : () => setState(() => signup = !signup),
                    child: Text(
                      signup
                          ? 'Already have an account? Sign in'
                          : 'New user? Create an account',
                    ),
                  ),
                  requestBanner(),
                  StatusText(message),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rateScreen() {
    return Scaffold(
      backgroundColor: const Color(0xffedf5f3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('BEFORE YOU START'),
                  Text(
                    'Set your hourly rate.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: rateController,
                    icon: Icons.attach_money,
                    hint: '35.00',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: busy ? 'Saving...' : 'Continue',
                    icon: Icons.check,
                    loading: busy,
                    onPressed: busy ? null : saveSettings,
                  ),
                  requestBanner(),
                  StatusText(message),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget workScreen() {
    final day = week.days[activeIndex];
    final running = activeTimer?.weekStart == week.weekStart &&
        activeTimer?.dayIndex == activeIndex;
    final completed = day.start.isNotEmpty && day.end.isNotEmpty && !running;
    final seconds = running
        ? now.difference(activeTimer!.startedAt).inSeconds -
            day.breakMinutes * 60
        : (dailyHours[activeIndex] * 3600).round();
    final hoursText = dailyHours[activeIndex].toStringAsFixed(running ? 4 : 2);
    final payText = running
        ? '\$${(dailyHours[activeIndex] * rate).toStringAsFixed(4)}'
        : money(dailyHours[activeIndex] * rate);

    return RefreshIndicator(
      onRefresh: loadAll,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          header(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Hours worked',
                  value: hoursText,
                  animate: running,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCard(
                  label: 'Earned so far',
                  value: payText,
                  green: true,
                  animate: running,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        day.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        day.date,
                        style: const TextStyle(color: Color(0xff66737b)),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: loadAll, icon: const Icon(Icons.refresh)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(18),
            tinted: running,
            child: Column(
              children: [
                ClockFace(
                  seconds: seconds,
                  running: running,
                  completed: completed,
                ),
                const SizedBox(height: 10),
                Text(
                  running
                      ? 'LIVE SHIFT TIMER'
                      : completed
                          ? 'TODAY SAVED'
                          : 'TAP START TO PUNCH IN',
                  style: const TextStyle(
                    color: Color(0xff1d6f68),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SmallMetric(
                  label: 'This week',
                  value: '${weeklyHours.toStringAsFixed(2)} hrs',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SmallMetric(
                  label: 'Estimated pay',
                  value: money(weeklyPay),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SmallMetric(
                  label: 'Status',
                  value: week.isPaid ? 'Paid' : 'Unpaid',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            color: running ? const Color(0xffa1432f) : const Color(0xff17212b),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  running
                      ? 'SHIFT IS RUNNING'
                      : completed
                          ? 'SHIFT COMPLETED'
                          : 'READY FOR TODAY',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                RollingText(
                  running
                      ? durationText(seconds)
                      : completed
                          ? 'Done'
                          : 'Start when ready',
                  color: Colors.white,
                  active: running,
                  size: 18,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: busy
                      ? (running ? 'Stopping...' : 'Starting...')
                      : running
                          ? 'Stop shift'
                          : completed
                              ? 'Completed'
                              : 'Start shift',
                  icon: running || completed ? Icons.stop : Icons.play_arrow,
                  loading: busy,
                  inverted: true,
                  onPressed:
                      busy || completed ? null : () => toggleTimer(activeIndex),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DetailChip(label: 'Start', value: formatTime(day.start)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DetailChip(label: 'End', value: formatTime(day.end)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DetailChip(
                  label: 'Hours',
                  value: hoursText,
                  animate: running,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          NoteEditor(
            key: ValueKey('${day.date}-${day.notes}'),
            initialNote: day.notes,
            enabled: !busy,
            onSave: (value) => saveNote(activeIndex, value),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: busy || running ? null : () => clearDay(activeIndex),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xfffff2ee),
                foregroundColor: const Color(0xffa1432f),
                side: const BorderSide(color: Color(0xffffd8cf)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text(
                'Clear hours for today',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          StatusText(message),
        ],
      ),
    );
  }

  Widget dashboardScreen() {
    final allHours = weeks.fold<double>(
      0,
      (sum, item) =>
          sum +
          item.days.fold<double>(
            0,
            (daySum, day) => daySum + calculateDayHours(day),
          ),
    );
    final unpaid = weeks.where((item) => !item.isPaid).toList();
    final enrichedWeeks = weeks
        .map(
          (item) => WeekSummary(
            week: item,
            hours: item.days.fold<double>(
              0,
              (sum, day) => sum + calculateDayHours(day),
            ),
          ),
        )
        .toList();
    return RefreshIndicator(
      onRefresh: loadAll,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          header(),
          const SizedBox(height: 12),
          MetricCard(
            label: 'Total money earned',
            value: money(allHours * rate),
            green: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SmallMetric(
                  label: 'Total hours',
                  value: allHours.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SmallMetric(
                  label: 'Unpaid weeks',
                  value: unpaid.length.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          paymentStatusSection(enrichedWeeks),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('HOURLY RATE'),
                AppTextField(
                  controller: rateController,
                  icon: Icons.attach_money,
                  hint: '35.00',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: busy ? 'Saving...' : 'Save rate',
                  icon: Icons.save_outlined,
                  loading: busy,
                  onPressed: busy ? null : saveSettings,
                ),
              ],
            ),
          ),
          StatusText(message),
        ],
      ),
    );
  }

  Widget paymentStatusSection(List<WeekSummary> enrichedWeeks) {
    final visibleWeeks = enrichedWeeks.where((item) {
      if (weekView == 'paid') return item.week.isPaid;
      if (weekView == 'unpaid') return !item.week.isPaid;
      return true;
    }).toList();
    final viewHours =
        visibleWeeks.fold<double>(0, (sum, item) => sum + item.hours);
    final viewPay = viewHours * rate;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => paymentOpen = !paymentOpen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Payment status'),
                        const SizedBox(height: 5),
                        Text(
                          weekView == 'paid'
                              ? 'Paid weeks'
                              : weekView == 'all'
                                  ? 'All saved weeks'
                                  : 'Weeks not paid',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${viewHours.toStringAsFixed(2)} hours',
                        style: const TextStyle(
                          color: Color(0xff66737b),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        viewPay == 0 ? '--' : money(viewPay),
                        style: TextStyle(
                          color: weekView == 'paid'
                              ? const Color(0xff17212b)
                              : const Color(0xff178a53),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    paymentOpen ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xff1d6f68),
                  ),
                ],
              ),
            ),
          ),
          if (paymentOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'unpaid', label: Text('Unpaid')),
                      ButtonSegment(value: 'paid', label: Text('Paid')),
                      ButtonSegment(value: 'all', label: Text('All')),
                    ],
                    selected: {weekView},
                    onSelectionChanged: (selected) =>
                        setState(() => weekView = selected.first),
                  ),
                  const SizedBox(height: 10),
                  if (visibleWeeks.isEmpty)
                    Text(
                      'No $weekView weeks to show.',
                      style: const TextStyle(
                        color: Color(0xff66737b),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    ...visibleWeeks.map(
                      (item) => WeekBrowserItem(
                        summary: item,
                        selected: item.week.weekStart == week.weekStart,
                        rate: rate,
                        onTap: () async {
                          await loadWeek(item.week.weekStart);
                          setState(() => tab = 2);
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget recordsScreen() {
    final locked = activeTimer != null;

    return RefreshIndicator(
      onRefresh: loadAll,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          header(),
          const SizedBox(height: 12),
          if (locked) const RecordsLockBanner(),
          RecordsHero(
            weekStart: week.weekStart,
            paid: week.isPaid,
            hours: weeklyHours,
            pay: weeklyPay,
          ),
          const SizedBox(height: 12),
          RecordsToolbar(
            locked: locked,
            paid: week.isPaid,
            weekStart: week.weekStart,
            onPrevious: () => navigateWeek('previous'),
            onCurrent: () => navigateWeek('current'),
            onNext: () => navigateWeek('next'),
            onSavedWeeks: showSavedWeeksPicker,
            onTogglePaid: () => togglePaid(week),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Timesheet'),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'All days',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: locked ? null : deleteWeek,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xfffff2ee),
                              foregroundColor: const Color(0xffa1432f),
                            ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locked
                            ? 'Week records are view-only while a shift is running. Stop the shift to edit.'
                            : 'Edit support is coming next in the Flutter app.',
                        style: const TextStyle(
                          color: Color(0xff66737b),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                ...week.days.map((day) => WebStyleDayRow(day: day)),
              ],
            ),
          ),
          if (weeks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: AppCard(
                child: Text(
                  'No saved weeks yet.',
                  style: TextStyle(
                    color: Color(0xff66737b),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          StatusText(message),
        ],
      ),
    );
  }

  Widget header() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xff17212b),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'PI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Punch In',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(color: Color(0xff66737b)),
                ),
              ],
            ),
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
    );
  }
}
