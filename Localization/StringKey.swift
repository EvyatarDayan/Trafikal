//
//  StringKey.swift
//  Trafikal
//

import Foundation

/// Keys for `Data/strings.json` UI copy.
enum StringKey: String, CaseIterable {
    // Tabs
    case tabStudy = "tab.study"
    case tabCategories = "tab.categories"
    case tabHome = "tab.home"
    case tabSigns = "tab.signs"
    case tabQuestions = "tab.questions"
    case tabSettings = "tab.settings"

    // Home
    case homeSignOfToday = "home.sign_of_today"
    case homeNoSignsLoaded = "home.no_signs_loaded"
    case homeStudyThisSign = "home.study_this_sign"
    case homeTestStatistics = "home.test_statistics"
    case homeNoTestsYet = "home.no_tests_yet"
    case homeTakePracticeTest = "home.take_practice_test"
    case homeLastTest = "home.last_test"
    case homeRecentAverage = "home.recent_average"
    case homeTestsTaken = "home.tests_taken"
    case homeBestScore = "home.best_score"
    case homeLastNTests = "home.last_n_tests"
    case homeAllTime = "home.all_time"
    case homePersonalBest = "home.personal_best"
    case homeKeepLearning = "home.keep_learning"
    case homeExploreDescription = "home.explore_description"
    case homeComingSoon = "home.coming_soon"

    // Study
    case studyTitle = "study.title"
    case studyAllSigns = "study.all_signs"
    case studyCardsInOrder = "study.cards_in_order"
    case studyPractice = "study.practice"
    case studyPracticeFooter = "study.practice_footer"
    case studyAboutImages = "study.about_images"
    case studyQuickStart = "study.quick_start"
    case studyPrevious = "study.previous"
    case studyNext = "study.next"
    case studyOf = "study.of"

    // Categories
    case categoriesTitle = "categories.title"
    case categoriesSignCount = "categories.sign_count"
    case categoriesSearch = "categories.search"

    // Sign categories
    case categoryWarningTitle = "category.warning.title"
    case categoryWarningSubtitle = "category.warning.subtitle"
    case categoryPriorityTitle = "category.priority.title"
    case categoryPrioritySubtitle = "category.priority.subtitle"
    case categoryProhibitionTitle = "category.prohibition.title"
    case categoryProhibitionSubtitle = "category.prohibition.subtitle"
    case categoryMandatoryTitle = "category.mandatory.title"
    case categoryMandatorySubtitle = "category.mandatory.subtitle"
    case categoryInformationTitle = "category.information.title"
    case categoryInformationSubtitle = "category.information.subtitle"
    case categoryAdditionalTitle = "category.additional.title"
    case categoryAdditionalSubtitle = "category.additional.subtitle"

    // Sign quiz (Signs tab)
    case signsTitle = "signs.title"
    case signsInstructions = "signs.instructions"
    case signsStartNew = "signs.start_new"
    case signsPreviousResults = "signs.previous_results"
    case signsYourLastQuiz = "signs.your_last_quiz"
    case signsStartOver = "signs.start_over"
    case signsNoSigns = "signs.no_signs"
    case signsPreparing = "signs.preparing"
    case signsWhatDoesSignMean = "signs.what_does_sign_mean"
    case signsEnd = "signs.end"
    case signsRoadSignQuiz = "signs.road_sign_quiz"
    case testNextQuestion = "test.next_question"
    case testShowResults = "test.show_results"
    case testCorrectCount = "test.correct_count"
    case testIncorrectCount = "test.incorrect_count"
    case testScoreSummary = "test.score_summary"
    case testCorrectLabel = "test.correct_label"

    // Questions
    case questionsTitle = "questions.title"
    case questionsInstructions = "questions.instructions"
    case questionsStartNew = "questions.start_new"
    case questionsPreviousResults = "questions.previous_results"
    case questionsYourLastQuiz = "questions.your_last_quiz"
    case questionsTheoryQuiz = "questions.theory_quiz"
    case questionsStartOver = "questions.start_over"
    case questionsEnd = "questions.end"
    case questionsNoQuestions = "questions.no_questions"
    case questionsPreparing = "questions.preparing"

    // History
    case historyTitle = "history.title"
    case historyCompletedTests = "history.completed_tests"
    case historyFilterAll = "history.filter.all"
    case historyFilterSigns = "history.filter.signs"
    case historyFilterQuestions = "history.filter.questions"
    case historyEmptyTitle = "history.empty_title"
    case historyEmptyMessage = "history.empty_message"
    case historyEmptyFilteredTitle = "history.empty_filtered.title"
    case historyEmptyFilteredMessage = "history.empty_filtered.message"
    case historyGotIt = "history.got_it"
    case historyPercentCorrect = "history.percent_correct"
    case historyDetailFormat = "history.detail_format"

    // Settings
    case settingsTitle = "settings.title"
    case settingsSubtitle = "settings.subtitle"
    case settingsPreferences = "settings.preferences"
    case settingsLanguage = "settings.language"
    case settingsLanguageSubtitle = "settings.language_subtitle"
    case settingsDarkMode = "settings.dark_mode"
    case settingsDarkModeSubtitle = "settings.dark_mode_subtitle"
    case settingsTestHistory = "settings.test_history"
    case settingsClearHistory = "settings.clear_history"
    case settingsNoTestsSaved = "settings.no_tests_saved"
    case settingsRemoveTests = "settings.remove_tests"
    case settingsRemoveTestsOne = "settings.remove_tests_one"
    case settingsClearAlertTitle = "settings.clear_alert_title"
    case settingsClearAlertMessage = "settings.clear_alert_message"
    case settingsCancel = "settings.cancel"
    case settingsClear = "settings.clear"

    // Common
    case commonSuccess = "common.success"
    case commonCancel = "common.cancel"

    // Catalog errors
    case errorSignsMissing = "error.signs_missing"
    case errorSignsLoad = "error.signs_load"
    case errorTheoryMissing = "error.theory_missing"
    case errorTheoryLoad = "error.theory_load"

    // About
    case aboutSignImagesTitle = "about.sign_images.title"
    case aboutSignImagesBody = "about.sign_images.body"
    case aboutSource = "about.source"
    case aboutInProject = "about.in_project"
    case aboutCommonsLink = "about.commons_link"
}
