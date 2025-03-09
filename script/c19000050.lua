--邪魔兽-焚烧之虎
function c19000050.initial_effect(c)
	c:SetSPSummonOnce(19000050)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000050,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19000050.spcon1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(c19000050.spcon2)
	c:RegisterEffect(e2)
	--spsummon limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c19000050.sumlimit)
	c:RegisterEffect(e3)
	--ritual when summon/filp/sps
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19000050,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,19000050)
	e4:SetCondition(c19000050.condition)
	e4:SetTarget(c19000050.target)
	e4:SetOperation(c19000050.activate)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
function c19000050.cfilter(c)
	return c:IsFaceup() and (c:IsRank(9) or c:IsLevel(9))
end
function c19000050.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19000050.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function c19000050.spcon2(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c19000050.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
function c19000050.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
function c19000050.filter(c,e,tp)
	return c:IsLevel(9)
end
function c19000050.matfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function c19000050.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp):Filter(c19000050.matfilter,nil)
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,c19000050.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c19000050.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg=Duel.GetRitualMaterial(tp):Filter(c19000050.matfilter,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,c19000050.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
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
