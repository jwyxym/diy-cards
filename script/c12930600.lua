--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196
未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，把手卡的这张卡和手卡1只光属性以外的怪兽给对方观看才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.e1con)
	e1:SetCost(s.e1cost)
	e1:SetTarget(s.e1tg)
	e1:SetOperation(s.e1op)
	c:RegisterEffect(e1)
	-- ②：根据这张卡特殊召唤的回合，适用以下效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tg)
	e3:SetOperation(s.e3op)
	c:RegisterEffect(e3)
end
-- ①条件：主要阶段
function s.e1con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①cost过滤：手卡光属性以外的怪兽，且非公开，且与该卡组成的一组中存在可特召和可送墓的组合
function s.e1costfilter(c,ec,e,tp)
	if c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsPublic() or (not c:IsType(TYPE_MONSTER)) then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(s.e1spfilter,1,nil,g,e,tp)
end
-- 可特召且组内另一张可送墓
function s.e1spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToGrave,1,c)
end
-- ①cost
function s.e1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.e1costfilter,tp,LOCATION_HAND,0,1,c,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sc=Duel.SelectMatchingCard(tp,s.e1costfilter,tp,LOCATION_HAND,0,1,1,c,c,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,sc)
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①target
function s.e1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ①operation
function s.e1op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=fg:FilterSelect(tp,s.e1spfilter,1,1,nil,fg,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.SendtoGrave(g-sg,REASON_EFFECT)
	end
	-- 这个回合，自己不是光属性以外的超量·连接怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.e1limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
-- ①限制：非光属性的超量·连接怪兽不能从额外卡组特殊召唤
function s.e1limit(e,c,tp,sumtp,sumpos)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK)) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ②target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- ②-自己过滤
function s.e2afilter(c,ft,e,tp)
	return c:IsSetCard(0xa460) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ②-对方过滤
function s.e2bfilter(c,mg)
	return c:IsSetCard(0xa460) and c:IsType(TYPE_XYZ) and c:IsXyzSummonable(mg,#mg,#mg)
end
-- ②operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if Duel.GetTurnPlayer()==tp then
		-- ●自己：从卡组把1只「冥骸驱轮」怪兽加入手卡或者特殊召唤
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if not Duel.IsExistingMatchingCard(s.e2afilter,tp,LOCATION_DECK,0,1,nil,ft,e,tp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local g=Duel.SelectMatchingCard(tp,s.e2afilter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp)
		if g:GetCount()==0 then return end
		local tc=g:GetFirst()
		local th=tc:IsAbleToHand()
		local sp=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		if th and sp then
			op=Duel.SelectOption(tp,1190,1152)
		elseif th then
			op=0
		else
			op=1
		end
		if op==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- ●对方：只用包含这张卡相同纵列的其他怪兽作为超量素材，从额外卡组把1只「冥骸驱轮」超量怪兽超量召唤
		local cg=c:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
		local mg=cg:Filter(Card.IsCanBeXyzMaterial,nil,nil)
		mg:AddCard(c)
		if not Duel.IsExistingMatchingCard(s.e2bfilter,tp,LOCATION_EXTRA,0,1,nil,mg) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xg=Duel.SelectMatchingCard(tp,s.e2bfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		if xg:GetCount()>0 then
			Duel.XyzSummon(tp,xg:GetFirst(),mg)
		end
	end
end
-- ③条件
function s.e3con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- ③过滤：场上主要怪兽区域，有相邻空位的怪兽
function s.e3filter(c)
	local seq=c:GetSequence()
	local p=c:GetControler()
	if seq==5 then return Duel.CheckLocation(p,LOCATION_MZONE,1) end
	if seq==6 then return Duel.CheckLocation(p,LOCATION_MZONE,3) end
	return (5>seq and seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1))
end
-- ③target
function s.e3tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.e3filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.e3filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectTarget(tp,s.e3filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local seq=tc:GetSequence()
	local p=tc:GetControler()
	local flag=0
	if seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	if seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if seq==5 then flag=flag|(1<<1) end
	if seq==6 then flag=flag|(1<<3) end

	if p~=tp then flag=flag<<16 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local s2=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~flag)
	if p~=tp then s2=s2>>16 end
	local nseq=math.log(s2,2)
	e:SetLabel(nseq)
	Duel.Hint(HINT_ZONE,tp,s2)
end
-- ③operation
function s.e3op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local seq=e:GetLabel()
	if not tc:IsRelateToEffect(e) then return end
	local tseq=tc:GetSequence()
	local p=tc:GetControler()
	if tseq>4 or math.abs(tseq-seq)~=1 or not Duel.CheckLocation(p,LOCATION_MZONE,seq) then return end
	Duel.MoveSequence(tc,seq)
end
