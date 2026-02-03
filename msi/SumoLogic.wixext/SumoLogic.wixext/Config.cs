using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace SumoLogic.wixext
{
    public class Config
    {
        // Regex pattern matching the Go code: [^A-Za-z0-9_./=+\-@]
        // This matches any character that is NOT in the allowed set
        private static readonly Regex InvalidCollectorNamePattern = new Regex(@"[^A-Za-z0-9_./=+\-@]", RegexOptions.Compiled);

        private string collectorName;

        public string InstallationToken { get; set; }
        public Dictionary<string, string> CollectorFields { get; set; }
        public bool RemotelyManaged { get; set; }
        public bool Ephemeral { get; set; }
        public string OpAmpFolder { get; set; }
        public string Api { get; set; }
        public string OpAmpApi { get; set; }
        public string Timezone { get; set; }

        public string CollectorName
        {
            get => collectorName;
            set
            {
                if (!string.IsNullOrEmpty(value))
                {
                    ValidateCollectorName(value);
                    collectorName = value.Trim();
                }
                else
                {
                    collectorName = value;
                }
            }
        }

        public bool Clobber { get; set; }

        public Config() {
            this.CollectorFields = new Dictionary<string, string>();
        }

        public void SetCollectorFieldsFromTags(string tags)
        {
            if (tags.Length == 0) { return; }

            var tagsRx = new Regex(@"([^=,]+)=([^\0]+?)(?=,[^,]+=|$)", RegexOptions.Compiled);
            var matches = tagsRx.Matches(tags);

            if (matches.Count == 0)
            {
                throw new TagsSyntaxException("tags were provided with invalid syntax");
            }
            if (matches.Count > 10)
            {
                throw new TagsLimitExceededException("the limit of 10 tags was exceeded");
            }

            foreach (Match match in matches)
            {
                if (match.Groups.Count != 3)
                {
                    Console.WriteLine("Groups: {0}", match.Groups.Count);
                    var msg = string.Format("invalid syntax for tag: {0}", match.Value);
                    throw new TagSyntaxException(msg);
                }
                var key = match.Groups[1].Value.Trim();
                var value = match.Groups[2].Value.Trim();

                if (key.Length > 255)
                {
                    var msg = string.Format("tag key exceeds maximum length of 255: {0}", key);
                    throw new TagKeyLengthExceededException(msg);
                }
                if (value.Length > 200)
                {
                    var msg = string.Format("tag value exceeds maximum length of 200: {0}", value);
                    throw new TagValueLengthExceededException(msg);
                }

                this.CollectorFields.Add(key, value);
            }
        }

        private void ValidateCollectorName(string name)
        {
            // Trim the name for validation
            var trimmedName = name.Trim();

            // Check if the name is empty after trimming
            if (string.IsNullOrEmpty(trimmedName))
            {
                throw new CollectorNameEmptyException(
                    "collector name cannot be empty. Either do not set it to use the default name, or provide a valid name");
            }

            // collector name length limit is 114 characters because:
            // if clobber is not enabled and a collector with the same name exists,
            // we append a suffix like "-unix_timestamp" to make the name unique.
            // The maximum length of the random string is 13 characters, plus the hyphen makes it 14.
            // Therefore, to ensure the final name does not exceed 128 characters,
            // we limit the base collector name to 114 characters.
            if (trimmedName.Length > 114)
            {
                throw new CollectorNameLengthExceededException(
                    "collector name cannot exceed 114 characters");
            }

            // only Letters, numbers and _. / = + - @ are allowed
            if (InvalidCollectorNamePattern.IsMatch(trimmedName))
            {
                throw new CollectorNameInvalidCharactersException(
                    "collector name contains invalid characters; only letters, numbers and _. / = + - @ are allowed");
            }
        }
    }
}
