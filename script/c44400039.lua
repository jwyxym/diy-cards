-- 命定之外的相遇 (ID: 44400039)
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」真实卡号（已修正）

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)
	aux.AddSetNameMonsterList(c,SET_CRYSTAL_FLOWER)

	-- ①：可以从以下效果中选择其中１个发动（这个卡名的１个效果１回合只能选择１次）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②：场上有怪兽把卡装备的场合才能发动。墓地存在的这张卡在自己场上盖放。这个回合对方已经把效果发动的场合，再让这个效果盖放的这张卡可以在盖放回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	-- 全局监听：记录对方本回合是否发动过效果（使用独立 Flag 码 id+200 避免与 HOPT 冲突）
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(rp,id+200,RESET_PHASE+PHASE_END,0,1)
end

--------------------------------------------------------------------------------
-- ①效果：二选一（检索并炸手卡装备特召 / 按装备数+1破坏对方场上卡）
--------------------------------------------------------------------------------
function s.thfilter1(c)
	return c:IsSetCard(SET_CRYSTAL_FLOWER) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.dina_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
end

function s.eqdesfilter(c,e)
	return c:IsType(TYPE_EQUIP) and c:IsDestructable(e)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.dina_filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_DESTROY)
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 分支1：选卡组１只「水晶花」怪兽加入手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,tc)
			-- 那之后，可以把自己手卡任意数量的装备卡破坏，把那只怪兽特殊召唤
			local hg=Duel.GetMatchingGroup(s.eqdesfilter,tp,LOCATION_HAND,0,nil,e)
			if #hg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local dg=hg:Select(tp,1,#hg,nil)
				if Duel.Destroy(dg,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	else
		-- 分支2：选最多有那个装备的卡的数量＋１的对方场上的卡破坏
		local mg=Duel.GetMatchingGroup(s.dina_filter,tp,LOCATION_MZONE,0,nil)
		if #mg==0 then return end
		local max_eq=0
		for mc in aux.Next(mg) do
			local ct=mc:GetEquipCount()
			if ct>max_eq then max_eq=ct end
		end
		local max_des=max_eq+1
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,math.min(max_des,#dg),nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- ②效果：场上有怪兽被装备卡时墓地盖放（双重全局锁定，严格 1 回合 1 次）
--------------------------------------------------------------------------------
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetFlagEffect(tp,id+o*100)==0
			and c:IsSSetable()
	end
	Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 then
		-- 这个回合对方已经把效果发动的场合，再让这个效果盖放的这张卡可以在盖放回合发动
		if Duel.GetFlagEffect(1-tp,id+200)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end