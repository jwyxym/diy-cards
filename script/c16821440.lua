--神寂的大神巫
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)	
	--回到手卡
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(s.bhcon)
	e0:SetTarget(s.bhtg)
	e0:SetOperation(s.bhop)
	c:RegisterEffect(e0)
	--仪式召唤
   	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rsptg)
	e1:SetOperation(s.rspop)
	c:RegisterEffect(e1)
	--特殊召唤   
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--追加p呼    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.exptg)
	e3:SetOperation(s.expop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--回到手卡
    aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
end
function s.bhcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
function s.bhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.bhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xdf96) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
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
		local mg=Duel.GetRitualMaterialEx(tp)
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,s.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg=Duel.GetRitualMaterialEx(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,s.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
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
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_ONFIELD) and not eg:IsContains(e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.exptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.expop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,id+o*3)
	e1:SetValue(s.pendvalue)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.pendvalue(e,c)
	return c:IsSetCard(0xdf95,0xdf96)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_PENDULUM)
end