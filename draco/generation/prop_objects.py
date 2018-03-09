from sortedcontainers import SortedDict

class PropObjects:
    """
    Functions to retrieve objects for fields that require object values
    """

    @staticmethod
    def get_bin(max_bins):
        """
        Returns a bin object with given max_bins
        """
        return SortedDict({ 'maxbins': max_bins })

    @staticmethod
    def get_scale(scale_enum):
        """
        Returns a scale object for the given type.

        type -- `zero` or `log`
        """
        if (scale_enum == 'zero'):
            return  SortedDict({ 'zero': True })
        elif (scale_enum == 'log'):
            return SortedDict({ 'type': 'log' })
        else:
            raise ValueError('scale should be zero or log')
