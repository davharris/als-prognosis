# Predicting ALS symptom progression

Hi, I'm Dave Harris, and today I'll be telling you forcasting the progression of ALS (also known as Lou Gehrig's disease).

ALS is a neurodegenerative condition that causes paralysis, and it's surprisingly common: the lifetime risk is about 1 in 400 people.

# It's hard

Patients and their families want to know when they'll need a wheelchair or when they'll need full-time care, but even expert physicians have trouble making this kind of prediction well, which makes the disease even harder to deal with.

# Famous folks

Just to give a sense of how variable this disease is, here are two of the most famous patients. Lou Gehrig lived less than two years after he was diagnosed, while Stephen Hawking is still alive more than 50 years later.

# How sick will I be next year?

We can get information on anonymous ALS patients from the PRO-ACT database.

I'll be focusing on this "functional rating scale", which describes patients' ability to perform 10 basic tasks. 

Function on each task is reported on a scale from 4 (which indicates full function) to zero (which indicates no function). 

For example, if the task is Walking, then "4" is normal walking, and "0" is when you can't move your legs at all.

# The data

Okay, so we have time series data for each patient for 10 different types of daily tasks, 5 of which I've shown here.

How do we use this information to make predictions? 

There aren't any standard statistics or machine learning packages that are well-suited to this sort of problem, which involves ten different response variables over time, so I had to build my own statistical model.

I used the Stan probabilistic programming language and the "brms" package to specify the model, which I'll build up to over the next few slides, starting with the "Walking" task.

# Logistic regression / ordered logit

So, the simplest way to model Walking would be logistic regression. As time-since-onset increases, the probability that a given subject will be able to walk goes down.

Since we have five categories instead of two, we can use an extension of logistic regression called an ordered logit model. Its predictions look like this.

Now, we can start to make useful predictions. We can look at a patient a year after onset and see immediately if they've been losing function faster or slower than average, then make a personalized prediction. In the Stan model, this all happens using random effects for each patient's slopes and intercepts.

One thing that helps a lot here is that the progression rates are tightly correlated across tasks.  For instance, when subjects start losing the ability to climb stairs, that provides the model with a nice nice "early warning system" for the ability to walk on flat ground.

Likewise, these other clusters help the model use information from one task to make better predictions about the others.

# App

Once we have our predictions, we need to present them to doctors and patients.  So I built an app lets the doctor pull up a dashboard for each patient.  

Here is some demographic and medical information.

Below, predicted scores over the next two years are grouped by type: respiratory, bulbar (which means mouth and throat), and motor tasks involving the arms and legs. At a glance, the doctor can see that the patient can expect to lose additional motor function, but that they'll probably continue eating and breathing okay.

Now let's say the patient wants to know if they'll need a wheelchair one year from now. Clicking the "walking" task brings up their likely scores. This area marked "two" corresponds to walking with assistance like a cane, so that's the most likely scenario, but they could still lose that ability at any time.  

The doctor can also move their mouse to see the patient's projected scores at different points in the future.

# Model validation

Finally, we should make sure that the model's predictions are actually worth showing to doctors.

# The prediction task

To do this, I set up a prediction task. Here, time is the x-axis.

First, I showed the model the complete histories from a few hundred subjects, which included 12 surveys spaced a month or two apart.

For the other half of the subjects, I only showed the model the first three data points. Then, I asked it to predict how they'd answer about their health on the remaining 9 surveys.

# Accuracy

One way to evaluate a model is its accuracy: how often did the model's best guess about a patient's score turn out to be right? 

Since their are 5 possible scores, random guessing would give the right answer 20% of the time.

The decline in these ten lines show that it gets harder to make good predictions for each task as time goes on. Still, predictions for all ten tasks remain useful for well over a year.

# How sick?

The upshot of all of this is that, when ALS patients ask their doctors about planning for their futures, doctors will be able to make much more specific and accurate predictions.

# David J. Harris

