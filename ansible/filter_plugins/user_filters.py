#!/usr/bin/env python

class FilterModule(object):
    def filters(self):
        return {
            'filter_users_by_host': self.filter_users_by_host
        }

    def filter_users_by_host(self, user_vars_results, inventory_hostname, group_names):
        """Filter user metadata based on host matches.
        
        Args:
            user_vars_results: List of results from include_vars
            inventory_hostname: Current host being processed
            group_names: List of groups the current host belongs to
            
        Returns:
            List of filtered user metadata
        """
        # Extract user vars from results
        all_users = []
        for result in user_vars_results:
            if not result.get('ansible_facts', {}).get('_user_vars'):
                print("No user vars found in result")
                continue
            user = result['ansible_facts']['_user_vars']
            if not user.get('hosts'):
                print("No hosts found in user vars")
                continue
            
            # Check if user should be included based on host matching rules
            hosts = user['hosts']
            if (
                'all' in hosts or 
                inventory_hostname in hosts or 
                any(group in hosts for group in group_names)
            ):
                all_users.append(user)
        
        return all_users
