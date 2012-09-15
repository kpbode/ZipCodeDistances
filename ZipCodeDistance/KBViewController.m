//
//  KBViewController.m
//  ZipCodeDistance
//
//  Created by Karl Bode on 14.09.12.
//  Copyright (c) 2012 Karl Bode. All rights reserved.
//

#import "KBViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "KBZipCodeManager.h"

@interface KBViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong, readwrite) CLLocationManager *locationManager;
@property (nonatomic, strong, readwrite) CLGeocoder *geocoder;
@property (nonatomic, strong, readwrite) KBZipCodeManager *zipCodeManager;
@property (nonatomic, strong, readwrite) NSArray *zipCodes;
@property (nonatomic, strong, readwrite) NSMutableDictionary *distances;

@end

@implementation KBViewController {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        self.geocoder = [[CLGeocoder alloc] init];
        
        self.zipCodeManager = [[KBZipCodeManager alloc] init];
        
        NSString *zipCodesString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zip_codes.csv" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
        self.zipCodes = [zipCodesString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        self.distances = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _currentLocationLabel.text = @"Getting your location...";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_locationManager stopUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
    
    [_geocoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        _currentLocationLabel.text = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        NSString *currentZipCode = [placemark.addressDictionary valueForKey:@"ZIP"];
        
        NSLog(@"current zip code: %@", currentZipCode);
        
        for (NSString *zipCode in _zipCodes) {
            
            double distance = [_zipCodeManager distanceBetweenZipCode1:currentZipCode andZipCode2:zipCode] / 1000.0;
            [_distances setObject:@(distance) forKey:zipCode];
        }
        
        self.zipCodes = [_zipCodes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSNumber *distance1 = [_distances objectForKey:obj1];
            NSNumber *distance2 = [_distances objectForKey:obj2];
            
            if (distance1 == nil || distance2 == nil) {
                return NSOrderedSame;
            }
            
            return [distance1 compare:distance2];
        }];
        
        [_zipCodeTableView reloadData];
     
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_zipCodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ZipCodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *zipCode = [_zipCodes objectAtIndex:indexPath.row];
    NSString *locationName = [_zipCodeManager nameForZipCode:zipCode];
    
    NSNumber *distance = [_distances objectForKey:zipCode];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", zipCode, locationName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i km", [distance integerValue]];
    
    return cell;
}

@end
