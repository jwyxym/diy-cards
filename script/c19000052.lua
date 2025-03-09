--邪魔兽-堕落之龙
function c19000052.initial_effect(c)
	c:SetSPSummonOnce(19000052)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000052,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19000052.spcon1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(c19000052.spcon2)
	c:RegisterEffect(e2)
	--spsummon limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c19000052.sumlimit)
	c:RegisterEffect(e3)
	--ritual when remove
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19000052,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,19000052)
	e4:SetCondition(c19000052.condition)
	e4:SetTarget(c19000052.target)
	e4:SetOperation(c19000052.activate)
	c:RegisterEffect(e4)
end
function c19000052.cfilter(c)
	return c:IsFaceup() and (c:IsRank(9) or c:IsLevel(9))
end
function c19000052.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19000052.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function c19000052.spcon2(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c19000052.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
function c19000052.ccfilter(c,tp)
	return c:IsPreviousControler(1-tp)
end
function c19000052.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(c19000052.ccfilter,1,nil,tp)
end
function c19000052.filter(c,e,tp)
	return c:IsLevel(9)
end
function c19000052.matfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function c19000052.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp):Filter(c19000052.matfilter,nil)
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,c19000052.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c19000052.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg=Duel.GetRitualMaterial(tp):Filter(c19000052.matfilter,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,c19000052.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			tc:CompleteProcedure()
		end
		Duel.SpecialSummonComplete()
	end
end

