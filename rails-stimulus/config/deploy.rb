# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, 'rails-stimulus'
set :repo_url, 'git@github.com:guillaumebriday/modern-datatables.git'
set :repo_tree, 'rails-stimulus'
set :user, 'deploy'
set :deploy_to, "/home/#{fetch(:user)}/www/#{fetch(:application)}"
set :default_env, {
  'DATABASE_URL' => 'nothing'
}

set :puma_init_active_record, true
set :puma_preload_app, true
set :puma_env, 'production'
set :puma_workers, 3
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}_puma.sock"
append :linked_files, 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'node_modules', 'public/packs'

namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        upload! 'config/master.key', "#{shared_path}/config/master.key" unless test("[ -f #{shared_path}/config/master.key ]")
      end
    end
  end

  after :finishing, :restart do
    # Overwriting puma:restart to ensure that puma is running. Effectively, we are just starting Puma.
    # A solution to this should be found.
    invoke 'puma:stop'
    invoke 'puma:start'
  end
end

after 'deploy:updated', 'assets:precompile'

namespace :assets do
  task :precompile do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'assets:precompile'
        end
      end
    end
  end
end
