//
//  CategoryViewController.m
//  Hack4Culture
//
//  Created by Prometheus on 4/16/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "CategoryViewController.h"
#import "RequestHelper.h"
#import "CategoryCell.h"

@implementation CategoryViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[RequestHelper categories] allKeys] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CategoryCell *cell = (CategoryCell*)[tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
    cell.title.text = [[[RequestHelper categories] allKeys] objectAtIndex:indexPath.row];
    [cell.categorySwitch setOn:[[[RequestHelper categorieFilters] objectAtIndex:indexPath.row] boolValue]];
    cell.row = indexPath.row;
    return cell;
}

@end
