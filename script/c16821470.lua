--神蛇的神醒
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,16821450)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.rsptg)
	e1:SetOperation(s.rspop)
	c:RegisterEffect(e1)
	--加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.thcon2)
	c:RegisterEffect(e3)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xdf96) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
end
function s.GetRitualLevel(c,rc)
	local lv=0
    if c:GetRank()>0 then 
    	lv=c:GetRank()
    else
    	lv=c:GetLevel()
    end
	return lv
end
function s.RitualCheckGreater(g,c,lv)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(s.GetRitualLevel,lv,c)
end
function s.RitualCheckEqual(g,c,lv)
	return g:CheckWithSumEqual(s.GetRitualLevel,lv,#g,#g,c)
end
function s.RitualCheck(g,tp,c,lv,greater_or_equal)
	-- Check if there's space to summonp
	if c:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,g,c)<=0 then
			return false
		end
	else
		if Duel.GetMZoneCount(tp,g,tp)<=0 then
			return false
		end
	end
	return s["RitualCheck"..greater_or_equal](g,c,lv) and (not c.mat_group_check or c.mat_group_check(g,tp))
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
function s.RitualCheckAdditionalLevel(c,rc)
	local raw_level=c:GetRitualLevel(rc)
    if c:GetRank()>0 then raw_level=c:GetRank(rc) end
	local lv1=raw_level&0xffff
	local lv2=raw_level>>16
	if lv2>0 then
		return math.min(lv1,lv2)
	else
		return lv1
	end
end
function s.RitualCheckAdditional(c,lv,greater_or_equal)
	if greater_or_equal=="Equal" then
		return	function(g)
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(s.RitualCheckAdditionalLevel,c)<=lv
				end
	else
		return	function(g,ec)
					if ec then
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(s.RitualCheckAdditionalLevel,c)-s.RitualCheckAdditionalLevel(ec,c)<=lv
					else
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
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
	local lv=level_function(c)
	aux.GCheckAdditional=s.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(s.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	aux.GCheckAdditional=nil
	return res
end
function s.rsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsSetCard,nil,0xdf95)
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,s.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsSetCard,nil,0xdf95)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.RitualUltimateFilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,s.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=s.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_PENDULUM)
end
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_MZONE) and not eg:IsContains(e:GetHandler())
end
function s.cfilter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsCode(16821450)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end