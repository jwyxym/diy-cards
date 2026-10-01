--神威解封
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61000203)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=aux.AddRitualProcGreater2(c,s.rsfilter,LOCATION_HAND+LOCATION_GRAVE,nil,nil,false,s.extraop)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re) and s.rlgl_r_l(rc)>0
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE)
end
function s.rcheck(gc)
	return  function(tp,g,c)
				return g:IsContains(gc)
			end
end
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,attack_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=c:GetLevel()
	aux.GCheckAdditional=s.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(s.RitualCheck,1,#mg,tp,c,lv,greater_or_equal)
	aux.GCheckAdditional=nil
	return res
end
function s.rlgl_r_l(c)
	if c:IsLevelAbove(1) then
		return c:GetLevel()
	elseif c:IsRankAbove(1) then
		return c:GetRank()
	elseif c:IsLinkAbove(1) then
		return c:GetLink()
	else
		return 0
	end
end
function s.RitualCheckAdditional(c,lv,greater_or_equal)
	if greater_or_equal=="Equal" then
		return  function(g)
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(s.rlgl_r_l)<=lv
				end
	else
		return  function(g,ec)
					if lv==0 then return #g<=1 end
					if ec then
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(s.rlgl_r_l)-s.rlgl_r_l(ec)<=lv
					else
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
function s.RitualCheckGreater(g,c,lv)
	if lv==0 then return false end
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(s.rlgl_r_l,lv)
end
function s.RitualCheckEqual(g,c,lv)
	if lv==0 then return false end
	return g:CheckWithSumEqual(s.rlgl_r_l,lv,#g,#g)
end
function s.RitualCheck(g,tp,c,lv,greater_or_equal)
	return s["RitualCheck"..greater_or_equal](g,c,lv) and Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
		mg1:AddCard(rc)
		aux.RCheckAdditional=s.rcheck(rc)
		local res=Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
		aux.RCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) then return end
	::cancel::
	local mg1=Duel.GetRitualMaterial(tp)
	mg1:AddCard(rc)
	aux.RCheckAdditional=s.rcheck(rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		aux.RCheckAdditional=nil
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.rsfilter(c,e,tp)
	return c:IsSetCard(61000203)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil,tp)
end
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	local ct=ev
	local label=Duel.GetFlagEffectLabel(0,21501505)
	if label then
		if ev==bit.rshift(label,16) then ct=bit.band(label,0xffff) end
	end
	if Duel.CheckChainTarget(ct,tc) then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
