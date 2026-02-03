using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SumoLogic.wixext
{
    public class EmptyConfigException : Exception
    {
        public EmptyConfigException(string message) { }
    }

    public class TagsSyntaxException : Exception
    {
        public TagsSyntaxException(string message) { }
    }

    public class TagSyntaxException : Exception
    {
        public TagSyntaxException(string message) { }
    }

    public class TagsLimitExceededException : Exception
    {
        public TagsLimitExceededException(string message) { }
    }

    public class TagKeyLengthExceededException : Exception
    {
        public TagKeyLengthExceededException(string message) { }
    }

    public class TagValueLengthExceededException : Exception
    {
        public TagValueLengthExceededException(string message) { }
    }

    public class MissingConfigurationException : Exception
    {
        public MissingConfigurationException(string message) { }
    }

    public class CollectorNameEmptyException : Exception
    {
        public CollectorNameEmptyException(string message) : base(message) { }
    }

    public class CollectorNameLengthExceededException : Exception
    {
        public CollectorNameLengthExceededException(string message) : base(message) { }
    }

    public class CollectorNameInvalidCharactersException : Exception
    {
        public CollectorNameInvalidCharactersException(string message) : base(message) { }
    }
}
