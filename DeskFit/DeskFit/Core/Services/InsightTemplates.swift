import Foundation

// MARK: - Pain-Specific Insight Templates

enum PainInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "{pain_area} Relief Focus",
            body: "Your {pain_area} discomfort may be connected to {sedentary} of sitting. Today's resets target this area with gentle mobility exercises that can help reduce tension buildup.",
            badge: "Personalized",
            cta: "Start your first reset"
        ),
        InsightTemplate(
            title: "Targeting Your {pain_area}",
            body: "Many desk workers experience {pain_area} tension from sustained positioning. Regular micro-movements can help maintain comfort throughout your workday.",
            badge: nil,
            cta: "See today's plan"
        ),
        InsightTemplate(
            title: "{pain_area} Care Today",
            body: "Based on your profile, we've included exercises that often help with {pain_area} discomfort. Even brief movement breaks can make a noticeable difference.",
            badge: "For You",
            cta: nil
        ),
        InsightTemplate(
            title: "Movement for {pain_area}",
            body: "Desk-related {pain_area} tension typically responds well to consistent, gentle stretching. Your plan today includes targeted exercises for this area.",
            badge: nil,
            cta: "View exercises"
        ),
        InsightTemplate(
            title: "{pain_area} + Desk Work",
            body: "With {sedentary} of daily sitting, your {pain_area} may benefit from movement variety. Today's resets are designed to address common desk-posture patterns.",
            badge: "Customized",
            cta: nil
        )
    ]
}

// MARK: - Sedentary Risk Insight Templates

enum SedentaryInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "Movement Matters",
            body: "Sitting {hours} hours daily can contribute to muscle tension. Breaking this up with brief resets {timing} may help maintain comfort and energy.",
            badge: "Health Tip",
            cta: "Start a quick reset"
        ),
        InsightTemplate(
            title: "Break Up Your Sitting",
            body: "Research suggests that regular movement breaks during {hours}+ hours of sitting can help reduce stiffness. Your resets are timed for {timing}.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Combat Desk Fatigue",
            body: "Extended sitting ({hours}) often leads to feeling stiff {timing}. A few minutes of targeted movement can help reset your body.",
            badge: "Did You Know?",
            cta: "See how it works"
        ),
        InsightTemplate(
            title: "Your Sitting Profile",
            body: "With {hours} of daily desk time, micro-movements become especially valuable. We've scheduled resets for when you typically feel most stiff.",
            badge: "Personalized",
            cta: nil
        )
    ]
}

// MARK: - Stiffness Timing Insight Templates

enum StiffnessInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "{time} Stiffness Pattern",
            body: "You mentioned feeling stiffest in the {time}. Your resets are timed to address this, targeting {focus} when it matters most.",
            badge: "Timed for You",
            cta: "Check your schedule"
        ),
        InsightTemplate(
            title: "Best Time to Reset",
            body: "Since {time} is when stiffness typically peaks for you, we've prioritized exercises for {focus} during these hours.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "{time} Movement Routine",
            body: "Consistent {time} movement can help address the tension buildup you experience. Today's plan focuses on {focus}.",
            badge: "Smart Timing",
            cta: "Start now"
        ),
        InsightTemplate(
            title: "Timed for Your Body",
            body: "Your {time} stiffness pattern suggests accumulated tension from sustained positioning. Brief resets at this time can help.",
            badge: nil,
            cta: nil
        )
    ]
}

// MARK: - Progress Insight Templates

enum ProgressInsightTemplates {
    static let all: [InsightTemplate] = improving + streak + restart + general

    static let improving: [InsightTemplate] = [
        InsightTemplate(
            title: "You're Improving!",
            body: "Your weekly average is trending upward. Consistent daily resets are clearly making a difference. Keep it going!",
            badge: "Trending Up",
            cta: nil
        ),
        InsightTemplate(
            title: "Positive Momentum",
            body: "Your scores show improvement over the past week. This kind of consistency often leads to noticeable changes in how you feel.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Great Progress",
            body: "Your movement routine is paying off. The upward trend in your scores reflects your commitment to daily resets.",
            badge: "Keep Going",
            cta: nil
        )
    ]

    static let streak: [InsightTemplate] = [
        InsightTemplate(
            title: "{streak}-Day Streak!",
            body: "You've completed resets {streak} days in a row. This consistency is building healthy movement habits.",
            badge: "On Fire",
            cta: "Keep the streak alive"
        ),
        InsightTemplate(
            title: "Streak Building",
            body: "Day {streak} of consistent movement! Your body is likely adapting to this healthy routine.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Consistency Wins",
            body: "A {streak}-day streak shows real commitment. Regular movement often leads to less stiffness over time.",
            badge: "Milestone",
            cta: nil
        )
    ]

    static let restart: [InsightTemplate] = [
        InsightTemplate(
            title: "Fresh Start Today",
            body: "Ready to get back into your routine? Even one reset can help you feel better. Every session counts.",
            badge: "New Day",
            cta: "Start your first reset"
        ),
        InsightTemplate(
            title: "Pick Up Where You Left Off",
            body: "It's been a few days since your last reset. No worries—jump back in with today's plan.",
            badge: nil,
            cta: "See today's plan"
        ),
        InsightTemplate(
            title: "Let's Get Moving",
            body: "Your body may be feeling the effects of recent inactivity. A quick reset can help get things flowing again.",
            badge: nil,
            cta: "Start now"
        )
    ]

    static let general: [InsightTemplate] = [
        InsightTemplate(
            title: "Building Habits",
            body: "You've completed {sessions} sessions this week. Each one contributes to your overall comfort and mobility.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Week in Review",
            body: "Your weekly score of {score} reflects your movement consistency. Keep building on this foundation.",
            badge: nil,
            cta: nil
        )
    ]
}

// MARK: - Plan Insight Templates

enum PlanInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "Today's Focus",
            body: "You have {session_count} resets planned today, targeting {focus}. Each session is designed to address your specific needs.",
            badge: "Your Plan",
            cta: "View full plan"
        ),
        InsightTemplate(
            title: "Personalized Sessions",
            body: "Today's {session_count} resets focus on {focus}—the areas you identified during setup. Ready when you are.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Made for You",
            body: "Based on your profile, today targets {focus} with {session_count} quick sessions spread throughout your day.",
            badge: "Custom Plan",
            cta: "See the exercises"
        ),
        InsightTemplate(
            title: "Your Daily Resets",
            body: "We've scheduled {session_count} movement breaks to help with {focus}. Short, targeted sessions that fit your day.",
            badge: nil,
            cta: nil
        )
    ]
}

// MARK: - Motivational Insight Templates

enum MotivationalInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "Small Steps, Big Impact",
            body: "Just 5 minutes of movement can help shift how your body feels. Your next reset is ready when you are.",
            badge: "Motivation",
            cta: "Start a quick reset"
        ),
        InsightTemplate(
            title: "Your Body Will Thank You",
            body: "Taking time for movement is an investment in your comfort. A few minutes now can make a difference for hours.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Every Reset Counts",
            body: "Whether you're feeling stiff or not, regular movement helps maintain flexibility. Keep building the habit.",
            badge: "Daily Tip",
            cta: nil
        ),
        InsightTemplate(
            title: "Move for Energy",
            body: "Feeling sluggish? A brief movement break can help boost circulation and alertness. Give it a try.",
            badge: nil,
            cta: "Quick reset"
        ),
        InsightTemplate(
            title: "Consistency Over Intensity",
            body: "Short, daily movement sessions often have more impact than occasional long workouts. You're on the right track.",
            badge: "Pro Tip",
            cta: nil
        ),
        InsightTemplate(
            title: "Break the Cycle",
            body: "Sitting for long periods creates patterns of tension. Regular resets help break this cycle before discomfort builds.",
            badge: nil,
            cta: nil
        )
    ]
}

// MARK: - Recovery Insight Templates

enum RecoveryInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "Rest is Progress",
            body: "Your muscles adapt and recover between sessions. If you're feeling sore, lighter movement today can still help.",
            badge: "Recovery",
            cta: nil
        ),
        InsightTemplate(
            title: "Listen to Your Body",
            body: "Some days call for gentle movement rather than intense stretching. Your body knows what it needs.",
            badge: nil,
            cta: "Try a gentle reset"
        ),
        InsightTemplate(
            title: "Active Recovery",
            body: "Light movement on rest days can help maintain flexibility without overtaxing your body. Balance is key.",
            badge: "Wellness Tip",
            cta: nil
        ),
        InsightTemplate(
            title: "Gentle Movement Day",
            body: "Consider today a maintenance day. Even minimal movement helps keep joints mobile and muscles happy.",
            badge: nil,
            cta: nil
        )
    ]
}

// MARK: - Work Environment Insight Templates

enum WorkEnvironmentInsightTemplates {
    static let all: [InsightTemplate] = [
        InsightTemplate(
            title: "Desk Posture Check",
            body: "Working at {work_type} often leads to subtle posture shifts throughout the day. Your resets help counteract these patterns.",
            badge: "Workspace Tip",
            cta: nil
        ),
        InsightTemplate(
            title: "Work Smart, Move Often",
            body: "Your {work_type} setup means extended sitting is part of your day. Strategic movement breaks can help maintain comfort.",
            badge: nil,
            cta: nil
        ),
        InsightTemplate(
            title: "Environment Matters",
            body: "Whether you're at {work_type} or elsewhere, brief movement resets help your body adapt to sustained positions.",
            badge: "Did You Know?",
            cta: nil
        ),
        InsightTemplate(
            title: "Desk-Friendly Exercises",
            body: "Today's resets are designed for your {work_type} environment. Discreet, effective movements you can do anywhere.",
            badge: "Practical",
            cta: "View exercises"
        )
    ]
}

// MARK: - Daily Plan Item Protocol

/// Protocol for plan data needed by InsightEngine
protocol DailyPlanItem {
    var sessionCount: Int { get }
}

extension DailyPlan: DailyPlanItem {
    var sessionCount: Int {
        return self.sessions.count
    }
}
