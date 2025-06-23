-- Insert 5 realistic sample ideas with varying properties
INSERT INTO ideas (content, is_voice, priority, improved_text, created_at, updated_at) VALUES
                                                                                           (
                                                                                               'Create a mobile app that helps people track their daily water intake and sends reminders',
                                                                                               FALSE,
                                                                                               'high',
                                                                                               'Enhanced idea: Develop a mobile application that monitors daily hydration levels, sends personalized reminders based on user activity, and offers insights on hydration patterns. Consider adding social sharing features to encourage friends to stay hydrated together.',
                                                                                               NOW() - INTERVAL '2 days',
                                                                                               NOW() - INTERVAL '2 days'
                                                                                           ),
                                                                                           (
                                                                                               'Start a weekly podcast interviewing local entrepreneurs about their business journeys',
                                                                                               TRUE,
                                                                                               'medium',
                                                                                               'Improved concept: Launch a bi-weekly podcast featuring in-depth conversations with local business owners, focusing on their challenges and innovative solutions. Include a segment where they share their most valuable business lessons and create accompanying blog posts with key takeaways from each interview.',
                                                                                               NOW() - INTERVAL '7 days',
                                                                                               NOW() - INTERVAL '5 days'
                                                                                           ),
                                                                                           (
                                                                                               'Design a sustainable packaging solution for food delivery services to reduce plastic waste',
                                                                                               FALSE,
                                                                                               'high',
                                                                                               NULL,
                                                                                               NOW() - INTERVAL '14 days',
                                                                                               NOW() - INTERVAL '14 days'
                                                                                           ),
                                                                                           (
                                                                                               'Develop a browser extension that summarizes long articles and highlights key points',
                                                                                               FALSE,
                                                                                               'low',
                                                                                               'Enhanced concept: Create a browser extension that not only summarizes lengthy articles but also provides context from related sources, allows for customizable summary lengths, and includes a feature to save collections of summaries by topic for future reference.',
                                                                                               NOW() - INTERVAL '30 days',
                                                                                               NOW() - INTERVAL '25 days'
                                                                                           ),
                                                                                           (
                                                                                               'Create a community garden program for apartment buildings with shared rooftop spaces',
                                                                                               TRUE,
                                                                                               'medium',
                                                                                               NULL,
                                                                                               NOW() - INTERVAL '1 day',
                                                                                               NOW() - INTERVAL '1 day'
                                                                                           );