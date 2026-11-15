--罪律侦探 克莱门汀
local s,id,o=GetID()
function s.initial_effect(c)
	--①：这张卡在手卡·墓地存在的场合才能发动。确认卡组上方3张卡。有「罪律」卡的场合，那些卡全部加入手卡，自己1张手卡丢弃，选手卡·墓地1只「罪律」怪兽特殊召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--②：1回合1次，选包含自己场上怪兽的场上2只怪兽。种族·属性·等级·攻击力·守备力之内至少1个相同的场合，那些卡除外。这张卡直到连锁结束除外。（不取对象）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.gravefilter(c,e,tp)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.zlfilter(c)
	return c:IsSetCard(0xe9a) and c:IsAbleToHand()
end
function s.exlock(e,c)
	--这个回合，只能从额外卡组把融合怪兽特殊召唤
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	--确认卡组上方3张卡
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local zg=g:Filter(s.zlfilter,nil)
	--没有「罪律」卡的场合，其余处理不进行
	if zg:GetCount()==0 then return end
	--那些卡全部加入手卡
	Duel.SendtoHand(zg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,zg)
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	--自己1张手卡丢弃
	if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		Duel.BreakEffect()
	end
	--选手卡·墓地1只「罪律」怪兽特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--这个回合，自己不是融合怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.exlock)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.samefilter(c,tc)
	if c==tc then return false end
	if bit.band(c:GetRace(),tc:GetRace())~=0 then return true end
	if bit.band(c:GetAttribute(),tc:GetAttribute())~=0 then return true end
	if c:GetLevel()>0 and c:GetLevel()==tc:GetLevel() then return true end
	return c:GetAttack()==tc:GetAttack() or c:GetDefense()==tc:GetDefense()
end
function s.pairfilter(c,mg)
	return mg:IsExists(s.samefilter,1,c,c)
end
function s.otherfilter(c,tc)
	return c~=tc and c:IsFaceup()
end
function s.myfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		return mg:GetCount()>=2 and mg:FilterCount(s.myfilter,nil,tp)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,0,LOCATION_MZONE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local my=mg:Filter(Card.IsControler,nil,tp)
	if my:GetCount()==0 or mg:GetCount()<2 then return end
	--第一只必须是自己场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g1=Duel.SelectMatchingCard(tp,s.myfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local g2=Duel.SelectMatchingCard(tp,s.otherfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc1)
	local tc2=g2:GetFirst()
	if not tc2 then return end
	g1:Merge(g2)
	if s.samefilter(tc1,tc2) then
		--至少1项相同的场合，那些卡除外
		local selfin=g1:IsContains(c)
		Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
		--选的卡不包含自己的场合，这张卡直到连锁结束除外（包含自己时不再作一时除外处理）
		if not selfin and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
			and Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_CHAIN_END)
			e3:SetLabelObject(c)
			e3:SetOperation(s.retop)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	e:Reset()
	if not c or not c:IsLocation(LOCATION_REMOVED) or not c:IsFaceup() then return end
	local tp2=c:GetControler()
	if Duel.ReturnToField(c,POS_FACEUP_ATTACK)==0 then
		Duel.SpecialSummon(c,0,tp2,tp2,false,false,POS_FACEUP)
	end
end
