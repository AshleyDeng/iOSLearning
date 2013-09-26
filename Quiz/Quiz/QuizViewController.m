//
//  QuizViewController.m
//  Quiz
//
//  Created by Ashley on 2013-03-15.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import "QuizViewController.h"

@interface QuizViewController ()

@end

@implementation QuizViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Call the init method implement by the superclass
    self = [super initWithNibName: nibNameOrNil bundle:nibBundleOrNil];
    
    if (self){
        // Create two arrays and make the pointers point to them
        questions = [[NSMutableArray alloc] init];
        answers = [[NSMutableArray alloc] init];
        
        // Add questions and answers to the arrays
        [questions addObject:@"What is 7 + 7?"];
        [answers addObject:@"14"];
        
        [questions addObject:@"What is your cat's name?"];
        [answers addObject:@"Amy"];

        [questions addObject:@"What is your favorite color?"];
        [answers addObject:@"Black"];

    }
    // Return the address of the new object
    return self;
}

- (IBAction)showQuestion:(id)sender
{
    // Step tp the next question
    currentQuestionIndex++;
    
    // Am I past the last question?
    if (currentQuestionIndex == [questions count]){
        // Go back to the first question
        currentQuestionIndex = 0;
    }
    
    // Get the string at that index in the questions array
    NSString *question = [questions objectAtIndex:currentQuestionIndex];
    
    // Log the string to the console
    NSLog(@"displaying question: %@", question);
    
    // Display the string in the question field
    [questionField setText:question];
    
    // Clear the answer field
    [answerField setText:@"???"];
}

- (IBAction)showAnswer:(id)sender
{
    // What is the answer to the current question?
    NSString *answer = [answers objectAtIndex:currentQuestionIndex];
    
    // Display it in the answer field
    [answerField setText:answer];
}

@end
