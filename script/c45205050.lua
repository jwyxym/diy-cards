local s,id,o=GetID()
local SET_NORDIC_ASCENDANT=0x3042

if not s.synchro_overloaded then
	s.synchro_overloaded=true

	local old_check = Duel.CheckSynchroMaterial
	local old_select = Duel.SelectSynchroMaterial
	local old_tuner_check = Duel.CheckTunerMaterial
	local old_tuner_select = Duel.SelectTunerMaterial

	local function check_mc(syncard, f2)
		local tp=syncard:GetControler()
		return Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() and c:IsCanBeSynchroMaterial(syncard)
				and not c:IsType(TYPE_TUNER) and (not f2 or f2(c,syncard))
		end,tp,LOCATION_MZONE,0,1,nil)
	end

	local function get_sub_mg(syncard, mg)
		local tp=syncard:GetControler()
		local base_mg=mg or Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,0,nil,syncard)
		return base_mg:Filter(function(c)
			return c:IsType(TYPE_TUNER) or (c:IsCode(id) and not c:IsDisabled())
		end,nil)
	end

	local function check_single_tuner_synchro(syncard, f1, f2)
		local tp=syncard:GetControler()
		local mc=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() and c:IsType(TYPE_TUNER) and c:IsCanBeSynchroMaterial(syncard)
		end,tp,LOCATION_MZONE,0,nil):GetFirst()
		if not mc or syncard:GetLevel()~=6 then return false end
		local f1_ok = not f1 or f1(mc,syncard)
		local f2_ok = not f2 or f2(mc,syncard)
		return f1_ok and f2_ok and Duel.GetLocationCountFromEx(tp,tp,mc,syncard)>0
			and aux.MustMaterialCheck(mc,tp,EFFECT_MUST_BE_SMATERIAL)
	end

	Duel.CheckSynchroMaterial = function(syncard, f1, f2, minc, maxc, smat, mg)
		if check_single_tuner_synchro(syncard, f1, f2) then
			return true
		end
		if check_mc(syncard, f2) and minc and minc>=2 then
			local sub_mg=get_sub_mg(syncard, mg)
			if old_check(syncard, f1, f2, minc-1, maxc, smat, sub_mg) then
				return true
			end
		end
		return old_check(syncard, f1, f2, minc, maxc, smat, mg)
	end

	Duel.SelectSynchroMaterial = function(tp, syncard, f1, f2, minc, maxc, smat, mg)
		local mc=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() and c:IsType(TYPE_TUNER) and c:IsCanBeSynchroMaterial(syncard)
		end,tp,LOCATION_MZONE,0,nil):GetFirst()
		if check_single_tuner_synchro(syncard, f1, f2) and not old_check(syncard, f1, f2, minc, maxc, smat, mg) then
			return Group.FromCards(mc)
		end
		if check_mc(syncard, f2) and minc and minc>=2 then
			local sub_mg=get_sub_mg(syncard, mg)
			local can_normal=old_check(syncard, f1, f2, minc, maxc, smat, mg)
			local can_double=old_check(syncard, f1, f2, minc-1, maxc, smat, sub_mg)
			if can_double and not can_normal then
				return old_select(tp, syncard, f1, f2, minc-1, maxc, smat, sub_mg)
			elseif can_double and can_normal then
				if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
					return old_select(tp, syncard, f1, f2, minc-1, maxc, smat, sub_mg)
				end
			end
		end
		return old_select(tp, syncard, f1, f2, minc, maxc, smat, mg)
	end

	Duel.CheckTunerMaterial = function(syncard, tuner, f1, f2, minc, maxc, mg)
		if check_single_tuner_synchro(syncard, f1, f2) then
			return true
		end
		if check_mc(syncard, f2) and minc and minc>=2 then
			local sub_mg=get_sub_mg(syncard, mg)
			if old_tuner_check(syncard, tuner, f1, f2, minc-1, maxc, sub_mg) then
				return true
			end
		end
		return old_tuner_check(syncard, tuner, f1, f2, minc, maxc, mg)
	end

	Duel.SelectTunerMaterial = function(tp, syncard, tuner, f1, f2, minc, maxc, mg)
		local mc=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() and c:IsType(TYPE_TUNER) and c:IsCanBeSynchroMaterial(syncard)
		end,tp,LOCATION_MZONE,0,nil):GetFirst()
		if check_single_tuner_synchro(syncard, f1, f2) and not old_tuner_check(syncard, tuner, f1, f2, minc, maxc, mg) then
			return Group.FromCards(mc)
		end
		if check_mc(syncard, f2) and minc and minc>=2 then
			local sub_mg=get_sub_mg(syncard, mg)
			local can_normal=old_tuner_check(syncard, tuner, f1, f2, minc, maxc, mg)
			local can_double=old_tuner_check(syncard, tuner, f1, f2, minc-1, maxc, sub_mg)
			if can_double and not can_normal then
				return old_tuner_select(tp, syncard, tuner, f1, f2, minc-1, maxc, sub_mg)
			elseif can_double and can_normal then
				if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
					return old_tuner_select(tp, syncard, tuner, f1, f2, minc-1, maxc, sub_mg)
				end
			end
		end
		return old_tuner_select(tp, syncard, tuner, f1, f2, minc, maxc, mg)
	end

	local old_mix_filter1 = Auxiliary.SynMixFilter1
	Auxiliary.SynMixFilter1 = function(c,f1,f2,f3,f4,minc,maxc,syncard,mg,smat,gc,mgchk,goalchk)
		if c:IsCode(id) and c:IsType(TYPE_TUNER) and not c:IsDisabled() and f2 then
			local f1_ok = (not f1 or f1(c, syncard))
			local f2_ok = f2(c, syncard, c)
			if f1_ok and f2_ok then
				if syncard:GetLevel()==6 and minc==0 then
					return true
				end
				local sg = Group.FromCards(c)
				local mg2 = mg:Clone()
				mg2:RemoveCard(c)
				local nontuner_mg = mg2:Filter(function(card) return not card:IsType(TYPE_TUNER) end, nil)
				local res = false
				if f3 then
					res = nontuner_mg:IsExists(Auxiliary.SynMixFilter3, 1, sg, f3, f4, minc, maxc, syncard, nontuner_mg, smat, c, c, gc, mgchk, goalchk)
				else
					res = nontuner_mg:IsExists(Auxiliary.SynMixFilter4, 1, sg, f4, minc, maxc, syncard, nontuner_mg, smat, c, c, nil, gc, mgchk, goalchk)
				end
				if res then return true end
			end
		end
		return old_mix_filter1(c,f1,f2,f3,f4,minc,maxc,syncard,mg,smat,gc,mgchk,goalchk)
	end

	local old_mix_target = Auxiliary.SynMixTarget
	Auxiliary.SynMixTarget = function(f1,f2,f3,f4,minct,maxct,gc)
		local orig_tg = old_mix_target(f1,f2,f3,f4,minct,maxct,gc)
		return function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
			local mc = Duel.GetMatchingGroup(function(card)
				return card:IsFaceup() and card:IsCode(id) and card:IsType(TYPE_TUNER) and not card:IsDisabled() and card:IsCanBeSynchroMaterial(c)
			end,tp,LOCATION_MZONE,0,nil):GetFirst()
			if mc and f2 and (not f1 or f1(mc,c)) and f2(mc,c,mc) then
				if c:GetLevel()==6 and minct==0 then
					local g=Group.FromCards(mc)
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				end
				local mg
				if mg1 then mg=mg1:Filter(Card.IsCanBeSynchroMaterial,nil,c) else mg=Auxiliary.GetSynMaterials(tp,c) end
				local mg2=mg:Clone()
				mg2:RemoveCard(mc)
				local nontuner_mg = mg2:Filter(function(card) return not card:IsType(TYPE_TUNER) end, nil)
				local g4=Group.CreateGroup()
				local cg=nontuner_mg:Filter(Auxiliary.SynMixCheckRecursive,g4,tp,g4,nontuner_mg,0,minct,maxct,c,Group.FromCards(mc,mc),smat,gc,false,false,false)
				if #cg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local c4=cg:SelectUnselect(Group.FromCards(mc),tp,true,false,minct,maxct)
					if c4 then
						local g=Group.FromCards(mc,c4)
						g:KeepAlive()
						e:SetLabelObject(g)
						return true
					end
				end
			end
			return orig_tg(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
		end
	end
end

function s.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,s.matfilter,1)
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.matfilter(c,syncard)
	return c:IsSetCard(SET_NORDIC_ASCENDANT)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NORDIC_ASCENDANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end