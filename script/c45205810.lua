--圣诞老人
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),nil,nil,aux.FilterBoolFunction(Card.IsType,TYPE_FLIP),1,99)
	
	--①效果：特殊召唤时，从卡组·墓地把最多5只圣诞怪兽·2星以下反转怪兽装备，对方可选抽1，自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	
	--②效果：双方回合，选自己场上1只里侧守备怪兽变表侧守备
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
	--③效果：对方发动魔陷怪兽效果时，把装备的1只怪兽里侧守备特召，那个效果无效并破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end

function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x1FC6) or (c:IsType(TYPE_FLIP) and c:IsLevelBelow(2)))
		and (c:IsLocation(LOCATION_DECK) and c:IsSetCard(0x1FC6) or c:IsLocation(LOCATION_GRAVE))
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 or #g==0 then return end
	local max=math.min(#g,ft,5)
	local sg=g:Select(tp,1,max,nil)
	for tc in aux.Next(sg) do
		Duel.Equip(tp,tc,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(c)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	if Duel.IsExistingMatchingCard(Card.IsAbleToHand,1-tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local dg=Duel.SelectMatchingCard(1-tp,Card.IsAbleToHand,1-tp,LOCATION_DECK,0,1,1,nil)
		if #dg>0 then
			Duel.SendtoHand(dg,nil,REASON_EFFECT)
			Duel.ConfirmCards(tp,dg)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_SUMMON)
			e2:SetTargetRange(0,1)
			e2:SetReset(RESET_PHASE+PHASE_END,2)
			Duel.RegisterEffect(e2,tp)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			Duel.RegisterEffect(e3,tp)
		end
	end
end

function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and e:GetHandler():GetEquipCount()>0
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	if #eqg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=eqg:Select(tp,1,1,nil):GetFirst()
	if tc then
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.SpecialSummonComplete()
		if Duel.NegateActivation(ev) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end

return s