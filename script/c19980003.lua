--
function c19980003.initial_effect(c)
	aux.EnableUnionAttribute(c,aux.TRUE)
	--change atk
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_EQUIP)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetValue(c19980003.val)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1)
	--spsummon1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19980003,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_HAND)
	e2:SetCountLimit(1,19980003)
	e2:SetCost(c19980003.spcost)
	e2:SetTarget(c19980003.sptg)
	e2:SetOperation(c19980003.spop)
	c:RegisterEffect(e2)
	--spsummon2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19980003,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,19980003+100)
	e3:SetCost(c19980003.spscost)
	e3:SetTarget(c19980003.spstg)
	e3:SetOperation(c19980003.spsop)
	c:RegisterEffect(e3)
end
function c19980003.val(e,c)
	local tp=c:GetControler()
	local v=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	if v>0 then return (v/3) else return 0 end
end
function c19980003.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function c19980003.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19980003.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19980003.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19980003.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c19980003.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
end
function c19980003.spsfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsAttack(0) and c:IsLink(4) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c19980003.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		and Duel.IsExistingMatchingCard(c19980003.spsfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c19980003.spsop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19980003.spsfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19980003.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19980003.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c19980003.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_FISH)
end